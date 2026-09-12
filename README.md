<div align="center">

# 雾凇小鹤 Lite

**雾凇拼音 · 小鹤双拼 · 自用精简版**

一套开箱即用、专注小鹤双拼的 Rime 配置

[![Rime](https://img.shields.io/badge/Rime-小狼毫-blue?style=flat-square)](https://rime.im/)
[![双拼](https://img.shields.io/badge/双拼-小鹤-flypy?style=flat-square)](https://flypy.cc/)
[![语法模型](https://img.shields.io/badge/语法模型-万象-9cf?style=flat-square)](https://github.com/amzxyz/rime-wanxiang)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](#-许可)

</div>

---

## ✨ 特性

<table>
<tr>
<td width="50%">

**🎯 方案精简**
- 仅保留 **小鹤双拼** 一个方案
- 去掉全拼、其他双拼的冗余
- 配置干净，一目了然

</td>
<td width="50%">

**🧠 万象语法模型**
- 接入 **万象 LTS 语言模型**
- 整句输入更接近人话
- 候选标注 `∞` 一眼识别

</td>
</tr>
<tr>
<td width="50%">

**🔤 精准音节**
- 拼音音节严格区分
- 平翘舌各归其位
- 候选窗口每页 6 个

</td>
<td width="50%">

**📝 自定义短语**
- `custom_phrase_double.txt`
- 高频短语置顶（权重 99）
- 支持词频排序导入

</td>
</tr>
<tr>
<td width="50%">

**📊 输入统计**
- `urtj` 一键查看效率仪表盘
- 均速 / 峰速 / 字数 / 上屏数
- 平均编码 / 词组率 / 字词分布

</td>
<td width="50%">

**🔍 部件拆字**
- 内置 `radical_pinyin` 反查
- 打不出的字拆偏旁找
- 辅码检字更灵活

</td>
</tr>
</table>

---

## 📱 鸿蒙皮肤

内置自制皮肤 **「小鹤主题（双拼）」**，专为鸿蒙 [超越输入法](https://appgallery.huawei.com/app/detail?id=app.flytype.hmos.bim) 打造。

![小鹤主题预览](themes/小鹤主题（双拼）/res/preview.svg)

| 项目 | 内容 |
|:-----|:-----|
| **名称** | 小鹤主题（双拼） |
| **作者** | [_647Uni](https://github.com/zghnby0825) · 协助构建 [OpenClaw](https://github.com/openclaw/openclaw) |
| **平台** | HarmonyOS（hmos） |
| **版本** | v1.0.0 |
| **更新** | 2026-06-06 |

### 特色

- **滑动双功能** —— 每键上滑出符号、下滑出数字，不用切页
- **反查键** —— `` ` `` 一键小鹤音形反查
- **快捷图标** —— 语音识别 / 表情 / 剪切板 / 中英切换，一键直达
- **工具面板** —— 长按调出全选、剪切、复制、粘贴、清空、重建主题
- **底排优化** —— 空格上滑切英文，回车上滑开剪切板

### 键盘布局

按键宽度为**比例单位**（每行合计 100），底排采用 `25 / 10 / 40 / 25` 的配比：

| 行 | 布局 | 宽度配比 |
|:--:|:-----|:---------|
| 1 | Q W E R T Y U I O P | 10 × 10 |
| 2 | 〔空〕A S D F G H J K L〔空〕 | 5 + 10×9 + 5 |
| 3 | ⇧ Shift + Z X C V B N M + ⌫ | 15 + 10×7 + 15 |
| 4 | ?123 · ， · 空格 · ↵ | **25 / 10 / 40 / 25** |

> 字母键不显式设置宽度时默认 **10**（占满整行）；底排空格最大（40），回车与符号键等宽（25）。

### 图标资源

| 图标 | 用途 |
|:-----|:-----|
| `themes/小鹤主题（双拼）/res/To_Zh.svg` | 切回中文键盘 |
| `themes/小鹤主题（双拼）/res/To_En.svg` | 切到英文键盘 |
| `themes/小鹤主题（双拼）/res/yy.svg` | 语音识别 |
| `themes/小鹤主题（双拼）/res/jt.svg` | 剪切板 |
| `themes/小鹤主题（双拼）/res/bq.svg` | 表情 |

> 皮肤文件位于 `themes/`，布局定义见 `themes/小鹤主题（双拼）/theme.yaml`，元信息见 `themes/小鹤主题（双拼）/info.yaml`。

---


## 📂 目录结构

```
rime-ice-Lite-for-myself/
├── default.yaml                  # 全局设置、方案列表
├── double_pinyin_flypy.schema.yaml  # ★ 主方案（小鹤双拼）
├── rime_ice.dict.yaml            # 词库入口（挂载 cn_dicts/）
├── custom_phrase_double.txt      # ★ 自定义短语
│
├── cn_dicts/                     # 中文词库
│   ├── 8105.dict.yaml            #   常用字表
│   ├── base.dict.yaml            #   基础词库
│   ├── ext.dict.yaml             #   扩展词库
│   ├── tencent.dict.yaml         #   腾讯词向量（大词库）
│   ├── others.dict.yaml          #   杂项
│   └── 41448.dict.yaml           #   Unihan 大字表（默认未启用）
│
├── en_dicts/                     # 英文词库
│   ├── en.dict.yaml              #   英文主词库
│   ├── en_ext.dict.yaml          #   英文扩展
│   ├── cn_en.txt                 #   中英混输源表
│   └── cn_en_flypy.txt           #   中英混输（小鹤键位，由 cn_en.txt 生成）
│
├── melt_eng.schema.yaml          # 英文输入（次翻译器）
├── melt_eng.dict.yaml            # 英文词库入口（挂载 en_dicts/）
├── radical_pinyin.schema.yaml    # 部件拆字（反查/辅码）
├── radical_pinyin.dict.yaml      # 部件拆字码表
│
├── lua/                          # Lua 脚本
│   ├── flypy_cand_comment.lua    # ★ 候选类型标注
│   ├── flypy_stats.lua           # ★ 输入统计（urtj 查询）
│   ├── flypy/                    #   统计依赖（LevelDB 封装）
│   ├── corrector.lua             #   错音错字提示
│   ├── pin_cand_filter.lua       #   置顶候选项
│   └── ...
│
├── opencc/                       # Emoji 映射（emoji.json / emoji.txt / others.txt）
├── themes/                       # 鸿蒙皮肤「小鹤主题（双拼）」
├── symbols_caps_v.yaml           # V 模式符号
├── weasel.yaml                   # 小狼毫前端配置
└── squirrel.yaml                 # 鼠须管前端配置
```

---

## 🚀 快速开始

### 1. 安装前端

**桌面端（Rime 原生）**

| 平台 | 前端 |
|:----:|:-----|
| **Windows** | [小狼毫 Weasel](https://github.com/rime/weasel/releases) |
| **macOS** | [鼠须管 Squirrel](https://github.com/rime/squirrel/releases) |
| **Linux** | [ibus-rime](https://github.com/rime/ibus-rime) / [fcitx5-rime](https://github.com/fcitx/fcitx5-rime) |

**移动端（小鹤双拼）**

| 平台 | 输入法 |
|:----:|:-------|
| **HarmonyOS 鸿蒙** | [超越输入法](https://appgallery.huawei.com/app/detail?id=app.flytype.hmos.bim) |
| **Android** | [同文输入法 Trime](https://github.com/osfans/trime) / [仓输入法](https://github.com/imfuxiao/Hamster) |
| **iOS** | [仓输入法 Hamster](https://github.com/imfuxiao/Hamster) |

### 2. 部署配置

```bash
# 1. 把本仓库内容复制到 Rime 用户目录
#    Windows: %APPDATA%\Rime  或 自定义目录
# 2. 放入语言模型（见下方 ⚠️）
# 3. 重新部署
#    Windows: 托盘右键 → 重新部署
#    或运行: WeaselDeployer.exe /deploy
```

### 3. ⚠️ 语言模型（必需）

本配置使用**万象语法模型**，需自行下载模型文件：

```
wanxiang-lts-zh-hans.gram    # 约 400 MB
```

**放置位置**：**Rime 用户目录根**（按文件名解析，**请勿改名**）。

> 模型来源：[rime-wanxiang](https://github.com/amzxyz/rime-wanxiang)
> 模型体积大，故未随本仓库分发。**缺失时**仅语法模型整句功能不可用，其余输入不受影响。

---

## ⌨️ 键位速查（小鹤双拼）

<div align="center">

**声母**

| 键 | v | i | u | 其余 |
|:--:|:-:|:-:|:-:|:----:|
| 拼音 | zh | ch | sh | 同全拼 |

**韵母**

| 键 | q | w | e | r | t | y | o | p | s | d | f | g | h | j | k | l | z | x | c | v | b | n | m |
|:--:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| 韵母 | iu | ei | e | uan | ue | un | uo | ie | ong | ai | en | eng | ang | an | ing | iang | ou | ia | ao | ui | in | iao | ian |

</div>

---

## 🧩 特色说明

### 候选类型标注

启用 `flypy_cand_comment.lua` 后，候选注释会显示来源标记：

| 标记 | 含义 |
|:----:|:-----|
| `∞` | **万象语法模型**整句候选 |
| `+` | **自定义短语**（`custom_phrase_double.txt`） |
| `*` | **用户词**（`.userdb` 学习所得） |

### 长词优先

挂载了 `long_word_filter.lua`：当**同一个编码**下出现比首位候选更长的词时，把它提到第 `idx` 位。

但在**小鹤双拼**下它几乎不触发（实测：190 万个编码里只有 33 个存在「同码不同词长」，其中长词落在第 4 位之后的 —— **0 个**）。原因：

| | 全拼 | 小鹤双拼 |
|:--|:--|:--|
| 音节长度 | 1–6 键不等（`jie` / `xian`） | 固定 **2 键**（`jp` / `xm`） |
| 后果 | 不同字数的词可能同码 | 码长 ≈ 字数，**不同字数几乎不同码** |

- 例（全拼）：`xian` 同码有「先」「西安」，长词被压 → 滤镜有效
- 例（小鹤）：「先」= `xm`、「西安」= `xian`，**根本不同码** → 无从提升
- 仅提升**已有候选项**的顺序，不新增编码；不提升含英文 / 数字的候选项
- `count` = 提升词数（默认 2），`idx` = 插入位置（默认 4）

> 结论：该滤镜对小鹤双拼是「挂着无害、但几乎感觉不到」；如需精简可从 `engine/filters` 移除。

### 自定义短语

`custom_phrase_double.txt` 格式：`词<Tab>编码<Tab>权重`

```
词	编码	权重
标注	bnvu	42
```

- **分隔符必须是 Tab**（不是空格）
- **编码用双拼键位**（非全拼）
- 权重越大越靠前

### 输入统计

输入 **`urtj`** 查看效率仪表盘（数据可跨设备累计，存入 `stats.userdb`）：

```text
※ 输入统计 · 效率仪表盘
─────────────────────────
综合数据
  均速  120 字/分     上屏  12345
  峰速  210 字/分     字数  23456
─────────────────────────
核心效率
  平均编码   2.35 键/字
  词组连打   68.4 %
─────────────────────────
字词分布
  [1] 32%  ▓▓▓░░░░░░░
  [2] 41%  ▓▓▓▓░░░░░░
  [3] 15%  ▓▓░░░░░░░░
  [4]  8%  ▓░░░░░░░░░
  [+]  4%  ░░░░░░░░░░
─────────────────────────
方案：小鹤双拼
前端：小狼毫 v0.17.4
```

| 指标 | 含义 |
|:-----|:-----|
| **均速** | 按会话统计的平均速度（字/分） |
| **峰速** | 10 秒窗口内的最高速度（异常值已过滤） |
| **平均编码** | 每个字平均按键数，越低越高效 |
| **词组连打** | 多字词占比，越高说明越善用词组 |
| **字词分布** | 上屏 1/2/3/4/5+ 字词的占比 |

> 移植自 [万象拼音](https://github.com/amzxyz/rime-wanxiang) 的输入统计，精简为单一总档。
> 依赖 `lua/flypy/userdb.lua`（LevelDB 薄封装）。

---

## 🔧 常用命令

```bash
# 重新部署（修改配置后）
WeaselDeployer.exe /deploy

# 查看 Rime 日志
# Windows: %APPDATA%\Rime\rime.weasel.*.INFO.*.log
```

---

## 📖 参考

- [Rime 输入法引擎](https://rime.im/)
- [雾凇拼音 rime-ice](https://github.com/iDvel/rime-ice) — 本配置的上游
- [万象拼音](https://github.com/amzxyz/rime-wanxiang) — 语法模型
- [小鹤双拼官网](https://flypy.cc/)
- [Rime 定制指南](https://github.com/rime/home/wiki/CustomizationGuide)

---

## 📄 许可

本项目基于 [MIT License](LICENSE) 开源。

词库与方案部分来自 [雾凇拼音](https://github.com/iDvel/rime-ice)（MIT），
语法模型来自 [万象拼音](https://github.com/amzxyz/rime-wanxiang)。

---

<div align="center">

**自用配置 · 持续维护**

<sub>Made with ❤️ for 小鹤双拼</sub>

</div>
