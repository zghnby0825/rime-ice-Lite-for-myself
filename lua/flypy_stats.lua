-- flypy_stats.lua —— 输入统计（简化版 / 小鹤双拼专用）
-- 移植自 万象拼音 amzxyz/rime-wanxiang 的 input_statistics.lua，精简为：
--   · 单一总档：-tj 输出全部累计
--   · 保留峰速、字词分布、均速、平均编码、词组率
--   · 去掉段位称号、多档查询（今日/周/月/年/生涯）、多设备统计、历史区间
--
-- 依赖：lua/wanxiang/userdb.lua（万象的 LevelDB 薄封装）
--
-- 挂载（方案文件）：
--   engine/translators:
--     - lua_translator@*flypy_stats
--   （commit_notifier 由 lua_translator 的 init 自行连接）
--
-- 配置（方案根级）：
--   flypy_stats:
--     db_name: stats              # 统计数据库名 → stats.userdb
--     trigger: "-tj"              # 查询触发词
--     continuous_gap_ms: 1000     # 峰速连续输入间隔阈值
--     average_gap_ms: 5000        # 均速会话间隔阈值

local userdb = require("wanxiang/userdb")

local RECORD_SEPARATOR = " \t"
local STATS_C_MAX = 2147483000
local DEFAULT_CONTINUOUS_GAP_MS = 1000
local DEFAULT_AVERAGE_GAP_MS = 5000
local DEFAULT_MINIMUM_AVERAGE_SESSION_MS = 1000
local DEFAULT_MINIMUM_AVERAGE_TOTAL_MS = 15000
local PEAK_WINDOW_MS = 10000
local MAX_VALID_PEAK_CHARS_PER_MINUTE = 350
local MAX_VALID_PEAK_KEYS_PER_MINUTE = 900
local DEFAULT_MAX_SPEED_COMMIT_LENGTH = 10

local STATISTICS_PREFIX = "statistics/"
local DAY_PREFIX = STATISTICS_PREFIX .. "day/"

local function to_integer(value)
    value = tonumber(value) or 0
    if value ~= value or value == math.huge or value == -math.huge then value = 0 end
    value = value < 0 and math.ceil(value) or math.floor(value)
    return math.max(0, math.min(STATS_C_MAX, value))
end

local function parse_tail(tail)
    if type(tail) ~= "string" then return 0 end
    local c = tail:match("^c=([^%s\t]+)")
    c = tonumber(c)
    if not c or c < 0 or c ~= math.floor(c) then return 0 end
    return to_integer(c)
end

local function make_raw_key(key)
    return key
end

local function acquire_db(env)
    if env.stats_db then return env.stats_db end
    local db = userdb.LevelDb(env.stats_db_name)
    if not db or (not db:loaded() and not db:open()) then
        env.stats_db_error = true
        return nil
    end
    env.stats_db = db
    env.stats_db_error = nil
    return db
end

local function get_db(env)
    return env.stats_db or acquire_db(env)
end

local function release_read_accessor(env)
    env.stats_read_accessor = nil
end

local function get_read_accessor(env)
    if env.stats_read_accessor then return env.stats_read_accessor end
    local db = get_db(env)
    if not db then return nil end
    local accessor = db:query("")
    if not accessor then return nil end
    env.stats_read_accessor = accessor
    return accessor
end

local function release_db(env)
    release_read_accessor(env)
    env.stats_db = nil
    collectgarbage()
end

local function scan_prefix(env, prefix, handler)
    local accessor = get_read_accessor(env)
    if not accessor or not accessor:jump(prefix) then return end
    for raw_key, tail in accessor:iter() do
        if raw_key:sub(1, #prefix) ~= prefix then break end
        handler(raw_key, parse_tail(tail))
    end
end

local function monotonic_ms()
    if rime_api and rime_api.get_time_ms then
        return math.floor(rime_api.get_time_ms())
    end
    return os.time() * 1000
end

local function day_id(timestamp)
    local date = os.date("*t", timestamp or os.time())
    return string.format("%04d%02d%02d", date.year, date.month, date.day)
end

-- 中文（含扩展区）字数
local function is_chinese(code)
    return (code >= 0x4E00 and code <= 0x9FFF)
        or (code >= 0x3400 and code <= 0x4DBF)
        or (code >= 0x20000 and code <= 0x2A6DF)
        or (code >= 0x2A700 and code <= 0x2B73F)
        or (code >= 0x2B740 and code <= 0x2B81F)
        or (code >= 0x2B820 and code <= 0x2CEAF)
        or (code >= 0x2CEB0 and code <= 0x2EBEF)
        or (code >= 0x30000 and code <= 0x3134F)
        or (code >= 0x31350 and code <= 0x323AF)
        or (code >= 0x2EBF0 and code <= 0x2EE5F)
        or (code >= 0xF900 and code <= 0xFAFF)
        or (code >= 0x2F800 and code <= 0x2FA1F)
        or (code >= 0x2E80 and code <= 0x2EFF)
        or (code >= 0x2F00 and code <= 0x2FDF)
end

local function chinese_length(text)
    local count = 0
    for _, code in utf8.codes(text) do
        if is_chinese(code) then count = count + 1 end
    end
    return count
end

local function new_stats()
    return {
        characters=0, commits=0,
        code_keystrokes=0, code_characters=0,
        average_characters=0, average_milliseconds=0, average_sessions=0,
        peak_speed=nil,
        length_1=0, length_2=0, length_3=0, length_4=0, length_5_plus=0,
        lifetime_characters=0,
    }
end

local function stats_add(env, key, amount)
    local db = get_db(env)
    if env.stats_db_error or not db then return false end
    local raw_key = make_raw_key(key)
    if not raw_key then return false end

    local key_day = key:match("^statistics/day/(%d%d%d%d%d%d%d%d)/")
    if key_day and (not env.write_cache_day or key_day > env.write_cache_day) then
        env.write_cache = {}
        env.write_cache_day = key_day
    end

    local value = env.write_cache[raw_key]
    if value == nil then
        value = parse_tail(db:fetch(raw_key))
    end
    value = to_integer(value + amount)
    if not db:update(raw_key, string.format("c=%d d=0 t=0", value)) then
        env.stats_db_error = true
        return false
    end
    release_read_accessor(env)
    env.write_cache[raw_key] = value
    return true
end

local function reset_sample(sample)
    sample.started = nil
    sample.last_activity = nil
    sample.last_commit = nil
    sample.characters = 0
    sample.keystrokes = 0
    sample.day = nil
end

local function start_sample(sample, day, timestamp_ms)
    sample.started = timestamp_ms
    sample.last_activity = timestamp_ms
    sample.last_commit = nil
    sample.characters = 0
    sample.keystrokes = 0
    sample.day = day
end

local function sample_values(sample, minimum_ms)
    if not sample.started or not sample.last_commit or sample.characters < 2 then
        return nil
    end
    local milliseconds = sample.last_commit - sample.started
    if milliseconds < minimum_ms then return nil end
    return sample.day, sample.characters, milliseconds
end

local function finish_average(env)
    local day, characters, milliseconds = sample_values(
        env.average_sample, env.minimum_average_session_ms
    )
    reset_sample(env.average_sample)
    if not day then return false end
    local prefix = DAY_PREFIX .. day .. "/speed_average/"
    stats_add(env, prefix .. "characters", characters)
    stats_add(env, prefix .. "milliseconds", milliseconds)
    stats_add(env, prefix .. "sessions", 1)
    return true
end

local function peak_speed(characters, milliseconds)
    return math.max(0, math.floor(characters * 60000 / milliseconds + 0.5))
end

local function peak_key_speed(keystrokes, milliseconds)
    return math.max(0, math.floor(keystrokes * 60000 / milliseconds + 0.5))
end

local function finish_peak(env)
    local peak = env.peak_sample
    local day, characters, milliseconds = sample_values(peak, PEAK_WINDOW_MS)
    local keystrokes = peak.keystrokes or 0
    reset_sample(peak)
    if not day or keystrokes <= 0 then return false end
    local char_speed = peak_speed(characters, milliseconds)
    local key_speed = peak_key_speed(keystrokes, milliseconds)
    if char_speed > MAX_VALID_PEAK_CHARS_PER_MINUTE
        or key_speed > MAX_VALID_PEAK_KEYS_PER_MINUTE
    then
        return false
    end
    stats_add(env, string.format("%s%s/speed_peak_window_10s/%04d",
        DAY_PREFIX, day, char_speed), 1)
    return true
end

local function ensure_sample(sample, day, timestamp_ms, gap_ms, finish)
    if sample.started then
        local gap = timestamp_ms - (sample.last_activity or sample.started)
        if gap >= 0 and gap <= gap_ms and sample.day == day then return end
        finish()
    end
    start_sample(sample, day, timestamp_ms)
end

local function finish_stale(env, timestamp_ms)
    local peak = env.peak_sample
    if peak.started and timestamp_ms - (peak.last_activity or peak.started)
        > env.continuous_gap_ms
    then
        finish_peak(env)
    end
    local average = env.average_sample
    if average.started and timestamp_ms - (average.last_activity or average.started)
        > env.average_gap_ms
    then
        finish_average(env)
    end
end

local function observe_input_activity(env, input)
    local timestamp_ms = monotonic_ms()
    if not input or input == "" or input:sub(1, 1) == "/" then
        finish_stale(env, timestamp_ms)
        env.last_observed_input = input or ""
        return
    end
    if input == env.last_observed_input then return end
    env.last_observed_input = input
    local day = day_id()
    ensure_sample(env.average_sample, day, timestamp_ms, env.average_gap_ms,
        function() finish_average(env) end)
    ensure_sample(env.peak_sample, day, timestamp_ms, env.continuous_gap_ms,
        function() finish_peak(env) end)
    env.average_sample.last_activity = timestamp_ms
    env.peak_sample.last_activity = timestamp_ms
end

local function commit_to_speed(env, day, timestamp_ms, characters, code_length, allow_peak)
    ensure_sample(env.average_sample, day, timestamp_ms, env.average_gap_ms,
        function() finish_average(env) end)
    local average = env.average_sample
    average.last_activity = timestamp_ms
    average.last_commit = timestamp_ms
    average.characters = average.characters + characters

    if allow_peak then
        ensure_sample(env.peak_sample, day, timestamp_ms, env.continuous_gap_ms,
            function() finish_peak(env) end)
        local peak = env.peak_sample
        peak.last_activity = timestamp_ms
        peak.last_commit = timestamp_ms
        peak.characters = peak.characters + characters
        peak.keystrokes = peak.keystrokes + code_length
        if peak.last_commit - peak.started >= PEAK_WINDOW_MS then finish_peak(env) end
    else
        reset_sample(env.peak_sample)
    end
    env.last_observed_input = ""
end

local function is_valid_speed_commit(env, characters, code_length)
    if code_length <= 0 or characters > env.max_speed_commit_length then
        return false
    end
    return characters <= math.max(4, code_length * 2)
end

local function record_stats(env, characters, code_length, candidate_type)
    local timestamp_ms = monotonic_ms()
    local day = day_id()
    local prefix = DAY_PREFIX .. day .. "/"
    if not stats_add(env, prefix .. "text/characters", characters) then return end
    if code_length > 0 then
        stats_add(env, prefix .. "text/code_keystrokes", code_length)
        stats_add(env, prefix .. "text/code_characters", characters)
    end
    local field = characters == 1 and "commit_length/1"
        or characters == 2 and "commit_length/2"
        or characters == 3 and "commit_length/3"
        or characters == 4 and "commit_length/4"
        or "commit_length/5_plus"
    stats_add(env, prefix .. field, 1)

    if is_valid_speed_commit(env, characters, code_length) then
        commit_to_speed(env, day, timestamp_ms, characters, code_length,
            candidate_type ~= "user_table")
    else
        finish_peak(env)
        finish_average(env)
        env.last_observed_input = ""
    end
end

local function calculate_peak(peaks)
    local speeds, samples = {}, 0
    for speed, count in pairs(peaks) do
        if count > 0 then
            speeds[#speeds + 1] = speed
            samples = samples + count
        end
    end
    if samples == 0 then return nil end
    table.sort(speeds, function(a, b) return a > b end)
    local target = math.min(2, samples)
    local total, used = 0, 0
    for _, speed in ipairs(speeds) do
        local take = math.min(peaks[speed], target - used)
        total = total + speed * take
        used = used + take
        if used >= target then break end
    end
    return used > 0 and math.floor(total / used + 0.5) or nil
end

local function aggregate_statistics(env)
    local db = get_db(env)
    if not db then return nil end
    local stats, peaks = new_stats(), {}
    scan_prefix(env, STATISTICS_PREFIX, function(key, value)
        local day, field = key:match("^statistics/day/(%d%d%d%d%d%d%d%d)/(.+)$")
        if not day then return end
        if field == "text/characters" then
            stats.lifetime_characters = stats.lifetime_characters + value
            stats.characters = stats.characters + value
        elseif field == "text/code_keystrokes" then
            stats.code_keystrokes = stats.code_keystrokes + value
        elseif field == "text/code_characters" then
            stats.code_characters = stats.code_characters + value
        elseif field == "commit_length/1" then stats.length_1 = stats.length_1 + value
        elseif field == "commit_length/2" then stats.length_2 = stats.length_2 + value
        elseif field == "commit_length/3" then stats.length_3 = stats.length_3 + value
        elseif field == "commit_length/4" then stats.length_4 = stats.length_4 + value
        elseif field == "commit_length/5_plus" then stats.length_5_plus = stats.length_5_plus + value
        else
            local average_field = field:match("^speed_average/([^/]+)$")
            if average_field == "characters" then
                stats.average_characters = stats.average_characters + value
            elseif average_field == "milliseconds" then
                stats.average_milliseconds = stats.average_milliseconds + value
            elseif average_field == "sessions" then
                stats.average_sessions = stats.average_sessions + value
            else
                local speed = field:match("^speed_peak_window_10s/(%d%d%d%d)$")
                if speed then
                    speed = tonumber(speed)
                    peaks[speed] = (peaks[speed] or 0) + value
                end
            end
        end
    end)

    stats.commits = stats.length_1 + stats.length_2 + stats.length_3
        + stats.length_4 + stats.length_5_plus

    -- 未落盘的当前采样也计入
    local day, characters, milliseconds = sample_values(
        env.average_sample, env.minimum_average_session_ms)
    if day then
        stats.average_characters = stats.average_characters + characters
        stats.average_milliseconds = stats.average_milliseconds + milliseconds
        stats.average_sessions = stats.average_sessions + 1
    end
    day, characters, milliseconds = sample_values(env.peak_sample, PEAK_WINDOW_MS)
    if day then
        local speed = peak_speed(characters, milliseconds)
        peaks[speed] = (peaks[speed] or 0) + 1
    end
    if stats.average_milliseconds < env.minimum_average_total_ms then
        stats.average_characters = 0
        stats.average_milliseconds = 0
        stats.average_sessions = 0
    end

    stats.peak_speed = calculate_peak(peaks)
    if stats.peak_speed and stats.average_milliseconds > 0 then
        local average_speed = math.floor(
            stats.average_characters * 60000 / stats.average_milliseconds + 0.5)
        if stats.peak_speed < average_speed then
            stats.peak_speed = average_speed
        end
    end
    return stats.commits > 0 and stats or nil
end

local function draw_bar(percent)
    percent = math.max(0, math.min(100, tonumber(percent) or 0))
    local filled = math.floor(percent / 10)
    return string.rep("▓", filled) .. string.rep("░", 10 - filled)
end

local SOFTWARE_NAME = rime_api.get_distribution_code_name()

local function platform_info(name, version)
    local names = {
        Weasel="小狼毫", trime="同文输入法", hamster3="元书输入法",
        hamster="仓输入法", lyraime="灵韵输入法", xime="曦码输入法",
        ["Cobra​"]="元书输入法(PC)", default="超越输入法",
    }
    version = tostring(version or "")
    return names[name] or name or "",
        version:match("^([vV]?%d+%.%d+%.%d+)") or version
end

local function format_summary(data, env)
    if not data or data.commits == 0 then return "※ 暂无打字记录哦" end
    local average_code = data.code_characters > 0
        and string.format("%.2f", data.code_keystrokes / data.code_characters)
        or "--"
    local phrase_rate = data.characters > 0
        and (data.characters - data.length_1) / data.characters * 100 or 0
    local average_speed = data.average_milliseconds > 0
        and math.floor(data.average_characters * 60000
            / data.average_milliseconds + 0.5) or nil
    local p = {
        data.length_1 / data.commits * 100, data.length_2 / data.commits * 100,
        data.length_3 / data.commits * 100, data.length_4 / data.commits * 100,
        data.length_5_plus / data.commits * 100,
    }
    local software, version = platform_info(
        SOFTWARE_NAME, rime_api.get_distribution_version())
    local zwsp = "\226\128\139"
    return string.format(
        "※ 输入统计 · 效率仪表盘" .. zwsp .. "\n" ..
        "───────────────" .. zwsp .. "\n" ..
        "📊 综合数据" .. zwsp .. "\n" ..
        "  均速:%-5s 上屏:%d" .. zwsp .. "\n" ..
        "  峰速:%-5s 字数:%d" .. zwsp .. "\n" ..
        "───────────────" .. zwsp .. "\n" ..
        "⚡ 核心效率" .. zwsp .. "\n" ..
        "  平均编码：%s 键/字" .. zwsp .. "\n" ..
        "  词组连打：%.1f %%" .. zwsp .. "\n" ..
        "───────────────" .. zwsp .. "\n" ..
        "📈 字词分布" .. zwsp .. "\n" ..
        "  [1] %3d%% %s" .. zwsp .. "\n" ..
        "  [2] %3d%% %s" .. zwsp .. "\n" ..
        "  [3] %3d%% %s" .. zwsp .. "\n" ..
        "  [4] %3d%% %s" .. zwsp .. "\n" ..
        "  [+] %2d%% %s" .. zwsp .. "\n" ..
        "───────────────" .. zwsp .. "\n" ..
        "◉ 方案：%s" .. zwsp .. "\n" ..
        "◉ 前端：%s %s" .. zwsp,
        average_speed and tostring(average_speed) or "--", math.floor(data.commits),
        data.peak_speed and tostring(data.peak_speed) or "--",
        math.floor(data.characters),
        average_code, phrase_rate,
        math.floor(p[1]), draw_bar(p[1]), math.floor(p[2]), draw_bar(p[2]),
        math.floor(p[3]), draw_bar(p[3]), math.floor(p[4]), draw_bar(p[4]),
        math.floor(p[5]), draw_bar(p[5]), env.schema_name,
        software, version
    )
end

local function yield_msg(seg, text, icon)
    yield(Candidate("stat", seg.start, seg._end, text, icon or "🕰️"))
end

local function prepare_report(env)
    finish_stale(env, monotonic_ms())
end

local function on_commit(context, env)
    local text = context:get_commit_text()
    if not text or text == "" or text:sub(1, 1) == "/"
        or text:find("^[※◉🏆📊⚡📈]") then return end
    local characters = chinese_length(text)
    if characters == 0 then return end
    local candidate_type = ""
    local cand = context:get_selected_candidate()
    if cand then
        candidate_type = cand.type or ""
        local genuine = cand.get_genuine and cand:get_genuine() or nil
        if genuine and genuine.type then candidate_type = genuine.type end
    end
    local code = context.input or ""
    if code == "" then code = env.last_observed_input or "" end
    record_stats(env, characters, #code, candidate_type)
end

local function bounded_int(config, key, default, minimum, maximum)
    return math.max(minimum, math.min(maximum, config:get_int(key) or default))
end

local function init(env)
    local config = env.engine.schema.config
    env.schema_name = env.engine.schema.schema_name or "小鹤双拼"
    env.stats_db_name = config:get_string("flypy_stats/db_name") or "stats"
    if env.stats_db_name == "" then env.stats_db_name = "stats" end
    env.trigger = config:get_string("flypy_stats/trigger") or "-tj"
    env.continuous_gap_ms = bounded_int(config, "flypy_stats/continuous_gap_ms",
        DEFAULT_CONTINUOUS_GAP_MS, 200, 5000)
    env.average_gap_ms = bounded_int(config, "flypy_stats/average_gap_ms",
        DEFAULT_AVERAGE_GAP_MS, env.continuous_gap_ms, 30000)
    env.minimum_average_session_ms = bounded_int(config,
        "flypy_stats/minimum_average_session_ms",
        DEFAULT_MINIMUM_AVERAGE_SESSION_MS, 500, 10000)
    env.minimum_average_total_ms = bounded_int(config,
        "flypy_stats/minimum_average_total_ms",
        DEFAULT_MINIMUM_AVERAGE_TOTAL_MS, 3000, 120000)
    env.max_speed_commit_length = bounded_int(config,
        "flypy_stats/max_speed_commit_length",
        DEFAULT_MAX_SPEED_COMMIT_LENGTH, 1, 10)
    env.stats_db_error = nil
    env.stats_read_accessor = nil
    env.write_cache = {}
    env.write_cache_day = nil
    env.last_observed_input = ""
    env.average_sample = {}
    env.peak_sample = {}
    reset_sample(env.average_sample)
    reset_sample(env.peak_sample)
    acquire_db(env)
    env.stat_notifier = env.engine.context.commit_notifier:connect(
        function(context)
            release_read_accessor(env)
            on_commit(context, env)
        end
    )
end

local function fini(env)
    finish_peak(env)
    finish_average(env)
    env.last_observed_input = ""
    if env.stat_notifier then
        env.stat_notifier:disconnect()
        env.stat_notifier = nil
    end
    env.write_cache = nil
    env.write_cache_day = nil
    env.average_sample, env.peak_sample = nil, nil
    release_db(env)
end

local function translator(input, seg, env)
    observe_input_activity(env, input)
    if input ~= env.trigger then return end
    prepare_report(env)
    local data = aggregate_statistics(env)
    if not data and env.stats_db_error then
        return yield_msg(seg, "※ 统计数据库打开失败", "⚠️")
    end
    if not data then return yield_msg(seg, "※ 暂无打字记录哦") end
    yield(Candidate("stat", seg.start, seg._end, format_summary(data, env), "📊"))
end

return {init=init, func=translator, fini=fini}
