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
<td>

**🔤 平翘舌模糊音**
- `z/zh`、`c/ch`、`s/sh` 互容
- 南方口音友好
- 放在 `algebra` 最前，稳定生效

</td>
<td>

**📝 自定义短语**
- `custom_phrase_double.txt`
- 高频短语置顶（权重 99）
- 支持词频排序导入

</td>
</tr>
</table>

---

## 📂 目录结构

```
rime-ice-Lite-formyself/
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
│   └── cn_en_flypy.txt           #   中英混输（小鹤键位）
│
├── melt_eng.schema.yaml          # 英文输入（次翻译器）
├── radical_pinyin.schema.yaml    # 部件拆字（反查/辅码）
│
├── lua/                          # Lua 脚本
│   ├── sp_super_comment.lua      # ★ 候选类型标注
│   ├── corrector.lua             #   错音错字提示
│   ├── pin_cand_filter.lua       #   置顶候选项
│   └── ...
│
├── opencc/                       # 简繁 / Emoji 映射
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

启用 `sp_super_comment.lua` 后，候选注释会显示来源标记：

| 标记 | 含义 |
|:----:|:-----|
| `∞` | **万象语法模型**整句候选 |
| `+` | **自定义短语**（`custom_phrase_double.txt`） |
| `*` | **用户词**（`.userdb` 学习所得） |

### 模糊音（平翘舌）

```yaml
# 必须放在 speller/algebra 最前面！
- derive/^([zcs])h/$1/          # zh→z, ch→c, sh→s
- derive/^([zcs])([^h])/$1h$2/  # z→zh, c→ch, s→sh
```

> ⚠️ Rime 列表 patch 只能追加、不能前插，而模糊音有顺序要求。
> **放末尾无效，甚至会破坏双拼**——务必置于 `algebra` 开头。

### 自定义短语

`custom_phrase_double.txt` 格式：`词<Tab>编码<Tab>权重`

```
词	编码	权重
标注	bnvu	42
```

- **分隔符必须是 Tab**（不是空格）
- **编码用双拼键位**（非全拼）
- 权重越大越靠前

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
