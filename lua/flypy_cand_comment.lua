-- flypy_cand_comment.lua —— 按候选类型标注注释（仿万象 super_comment/cand_type 机制）
-- 2026-09-11 新建：候选类型标注滤镜（sentence→∞ / user_table→+ / user_phrase→*）。
--
-- 用途：启用语法模型（grammar）后，整句候选（type == "sentence"）由语言模型
--       打分产生，本滤镜按配置在候选注释中标注标记符（如 ∞），便于区分
--       「模型整句候选」与普通词库候选；同理可给自定义短语（custom_phrase）标 +。
--
-- 配置方法（方案文件根级，与万象方案写法一致）：
--   super_comment:
--     cand_type:
--       sentence: "∞"      # 键 = 候选 type，值 = 追加到注释末尾的标记
--       table: "+"         # 自定义短语（table_translator@custom_phrase）候选
--
-- 挂载方法（engine/filters，星号前缀 = lua/ 目录下的命名空间模块，无需 rime.lua 注册）：
--   - lua_filter@*flypy_cand_comment
--
-- 说明：
--   - 候选 type 由翻译器决定：script_translator 的整句候选为 "sentence"，
--     普通词条为 "phrase"/"user_phrase"，补全为 "completion"，可按需增配。
--     table_translator 的词条候选 type 为 "table"/"user_table"。
--   - 标记追加在原注释之后；原注释为空时直接显示标记。
--   - 本滤镜对全部段落生效，但只有配置了标记的候选类型会被改动，开销可忽略。

local M = {}

function M.init(env)
  env.marks = {}
  local config = env.engine.schema.config
  -- 逐一探测常见候选类型，读取 super_comment/cand_type/<type>
  local known_types = {
    "sentence", "phrase", "user_phrase", "completion",
    "punct", "table", "reverse_lookup", "user_table",
  }
  for _, t in ipairs(known_types) do
    local ok, mark = pcall(function()
      return config:get_string("super_comment/cand_type/" .. t)
    end)
    if ok and mark and mark ~= "" then
      env.marks[t] = mark
    end
  end
end

function M.func(input, env)
  local marks = env.marks
  for cand in input:iter() do
    local mark = marks[cand.type]
    if mark then
      local comment = cand.comment
      if comment and comment ~= "" then
        cand.comment = comment .. " " .. mark
      else
        cand.comment = mark
      end
    end
    yield(cand)
  end
end

return M
