---
name: gfishimage
description: |
  gfishimage — 手绘风格插画生成 + PicGo 图床上传一体化。
  通过兼容 Gemini 协议的 API 调用 NanoBananaPro 生成手绘漫画风格插画，生成后自动上传 PicGo 图床，输出图床链接。
  专为微信公众号技术文章配图设计。
  触发条件：
  (1) 用户说 /gfishimage 或 "生图"、"画一张"、"配图"
  (2) 用户说"手绘图"、"漫画风格"、"插画"、"信息图"
  (3) 用户说"公众号配图"、"文章配图"、"微信配图"
  (4) 用户说"上传图床"（单独上传已有图片）
  (5) 用户要求编辑/修改已生成的图片
  (6) 用户在写公众号文章过程中需要配图
---

# gfishimage — 手绘配图 + 图床上传

**一句话流程**：用户描述 → 构建手绘风提示词 → 生成图片 → 上传 PicGo → 输出图床链接 → 清理本地文件。

---

## 默认风格：手绘漫画

**除非用户明确要求其他风格，否则一律使用手绘漫画风格**：

| 维度 | 要求 |
|------|------|
| **线条** | 手绘粗线条、sketchy、doodle style、rough strokes |
| **纹理** | 蜡笔/马克笔质感（crayon/marker texture），禁止 3D 渲染 |
| **布局** | 横版 16:9 为主，大量留白，有组织的视觉流 |
| **文字** | 仅提取核心关键词（1-6 字），禁止论文式排版 |
| **色彩** | 柔和配色，不超过 4 种主色调，背景以白色/米白为主 |
| **禁止** | 禁止写实风格、禁止照片级渲染、禁止密集排版 |

### 文字语言规则（强制）

| 场景 | 语言 | 示例 |
|------|------|------|
| **通用内容文字** | **简体中文** | "用户输入"、"配置文件"、"环境变量" |
| **技术专有名词** | **保持英文原文** | PreToolUse、Hook、Bash、SSE、API、CLI、npm、pip |
| **混合场景** | 中文为主，技术词嵌英文 | "调用 Bash 工具"、"配置 Hook 拦截"、"通过 SSE 推送" |

**判断标准**：如果一个词在技术圈普遍用英文说（面试时你会用英文说的），就保持英文。其他一律简体中文。

---

## 场景智能识别

当用户提到以下场景时，自动匹配最佳参数：

### 公众号技术文章配图（默认场景）

用户说"公众号"、"文章配图"、"配图"、"微信"时：

| 参数 | 值 | 原因 |
|------|------|------|
| **宽高比** | `16:9` | 公众号正文图片最佳比例 |
| **分辨率** | `2K` | 清晰度与加载速度平衡 |
| **风格** | 手绘漫画 | 默认风格 |
| **文字** | 简体中文 + 技术词英文 | 技术读者群体 |

### 封面图 / 头图

用户说"封面"、"头图"、"首图"时：

| 参数 | 值 |
|------|------|
| **宽高比** | `2.35:1` 即 `21:9` |
| **分辨率** | `2K` 或 `4K` |
| **文字** | 标题级大字，简体中文 |

### 对比图 / 步骤图

用户说"对比"、"A vs B"、"步骤"、"流程"时：

| 参数 | 值 |
|------|------|
| **宽高比** | `16:9` |
| **布局** | 左右分栏（对比）或 纵向流程（步骤） |

### 竖版配图

用户说"竖版"、"手机端"、"小绿书"时：

| 参数 | 值 |
|------|------|
| **宽高比** | `9:16` |
| **分辨率** | `2K` |

---

## 提示词构建规则

**提示词用英文撰写**（NanoBananaPro 对英文理解更好），但图片中渲染的文字用简体中文（技术词保持英文）。

### 基础模板

```
A hand-drawn doodle infographic about [主题].
Style: sketchy doodle, rough strokes, crayon texture, marker coloring.
Layout: landscape 16:9, clean composition, generous whitespace, organized visual flow.
Content: [具体内容元素].
Colors: [不超过4种柔和色], white/cream background.
Text: [简体中文关键词，技术词保持英文，每个不超过6字].
Constraints: No 3D rendering, no photorealism, no dense text.
Playful and minimal.
```

### 示例：技术流程图

```
A hand-drawn doodle flowchart about Claude Code Hook mechanism.
Style: sketchy doodle, rough strokes, crayon texture, marker coloring.
Layout: landscape 16:9, vertical flow with 6 connected nodes, generous whitespace.
Content: 6 rounded boxes connected by arrows, each box contains a short label.
Colors: soft blue (#5B8DEF), warm amber (#F5A623), mint green (#7ED321), charcoal (#333333), white background.
Text in boxes: 用户输入, Hook拦截, 调用工具, PreToolUse, 工具执行, 回复完成.
Constraints: No 3D, no photorealism. Playful and minimal.
```

### 示例：概念对比图

```
A hand-drawn doodle comparison infographic about MCP vs A2A.
Style: sketchy doodle, rough strokes, crayon texture, marker coloring.
Layout: landscape 16:9, split left and right with a VS badge in center.
Left side: MCP box with tool icons. Right side: A2A box with agent icons.
Colors: left soft purple (#9B59B6), right soft teal (#1ABC9C), charcoal text, white background.
Text: 左侧 labels: MCP, 工具调用, stdio/SSE. 右侧 labels: A2A, Agent协作, HTTP/gRPC.
Constraints: No 3D, no photorealism.
```

更多提示词模板见 [references/prompt-templates.md](references/prompt-templates.md)。

---

## 首次安装配置

新用户首次使用 `/gfishimage` 前，必须先完成配置。**生图前先检测配置文件是否存在**：

```bash
cat ~/.gfishimage/config.json 2>/dev/null
```

**配置文件不存在时**，提示用户运行 setup：

> ⚠️ gfishimage 尚未配置。请在终端中运行以下命令完成首次配置：
>
> ```
> python ~/.claude/skills/gfishimage/scripts/generate_ikun.py --setup
> ```
>
> 配置向导会引导你输入：
> 1. **API Base URL** — 图片生成服务的地址
> 2. **API Key** — 你的 API 密钥
> 3. **生图模型** — 模型名称
>
> 兼容所有 Gemini 协议的 API 服务，不局限于特定供应商。

**配置文件位置**：`~/.gfishimage/config.json`

**配置文件格式**：
```json
{
  "base_url": "https://your-api-endpoint.example.com",
  "api_key": "sk-xxx",
  "model": "your-model-name"
}
```

**配置好后继续生图流程。配置未完成不生图。**

---

## 完整工作流

### Step 1: 解析用户需求

从用户描述中提取：
- **主题**：用户想表达什么内容
- **场景**：公众号配图 / 封面图 / 流程图 / 对比图 等（自动识别）
- **宽高比**：根据场景自动选择，默认 `16:9`
- **分辨率**：默认 `2K`
- **临时文件路径**：`/tmp/gfishimage_{YYYYMMDD}_{HHMM}_{主题}.png`

### Step 2: 构建提示词

按上方模板构建，注意：
- 图片中的文字内容用**简体中文**
- 技术专有名词（如 Hook、Bash、API、SSE、npm）保持**英文**
- 其他描述性文字一律**简体中文**

### Step 3: 生成图片

```bash
mkdir -p /tmp

python ~/.claude/skills/gfishimage/scripts/generate_ikun.py \
  --prompt "构建好的提示词" \
  --aspect-ratio [比例] \
  --size [分辨率] \
  --output /tmp/gfishimage_{YYYYMMDD}_{HHMM}_{主题}.png \
  --retry 3
```

### Step 4: 上传 PicGo 图床

**先检测 PicGo Server 是否可用**：

```bash
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:36677/upload
```

- 如果返回 HTTP 状态码（如 200、4xx）→ Server 正在运行，继续上传
- 如果无响应或连接失败 → **停止上传流程，提示用户**：

> ⚠️ PicGo Server 未运行。请执行以下操作后重试：
> 1. 打开 PicGo 应用 → 进入「PicGo-Server」设置 → 开启 Server（默认端口 36677）
> 2. 确认图床已配置（如 GitHub 图床、SM.MS 等）并设为默认
> 3. 确认 PicGo Server 状态为「已启动」
>
> 配置完成后，图片保存在本地：`/tmp/gfishimage_*.png`，可稍后手动上传

**PicGo Server 可用时，上传图片**：

```bash
curl -s http://127.0.0.1:36677/upload -F "files=@/tmp/gfishimage_{YYYYMMDD}_{HHMM}_{主题}.png"
```

返回 JSON：`{"success":true,"result":["https://cdn.jsdelivr.net/gh/.../xxx.png"]}`，从 `result[0]` 提取图床 URL。

### Step 5: 输出结果

**成功时输出**：

```
![](图床URL)
```

直接输出 Markdown 图片语法（不含描述文字），方便粘贴到文档。

### Step 6: 清理临时文件（强制，不可跳过）

**无论生图成功还是失败，只要上传完成，必须立即删除临时文件**：

```bash
rm -f /tmp/gfishimage_*.png
```

这是硬性要求，原因：
- `/tmp` 目录空间有限，残留图片会占用大量磁盘
- 本地文件只是中转态，图床 URL 已获得，本地文件无保留价值
- **每生成一张图，上传后必须立刻 rm，不允许批量清理**

**唯一例外**：PicGo 上传失败时，保留本地文件作为兜底，并输出本地路径提示用户手动上传。但用户确认已手动上传后，仍需删除。

---

## 单独上传图床

当用户说"上传图床"且提供了本地图片路径时，跳过生图，先检测 PicGo Server 再上传：

```bash
# 检测 Server
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:36677/upload

# Server 可用时上传
curl -s http://127.0.0.1:36677/upload -F "files=@/path/to/image.png"
```

若 Server 不可用，同样提示用户先配置并启动 PicGo Server。输出图床 URL。

---

## 图生图 / 编辑

用户上传图片 + 编辑描述，修改后重新上传。

```bash
python ~/.claude/skills/gfishimage/scripts/generate_ikun_edit.py \
  --input /path/to/original.png \
  --prompt "Redraw in hand-drawn doodle style: [编辑描述]. Maintain sketchy crayon texture." \
  --aspect-ratio 16:9 \
  --output /tmp/gfishimage_{YYYYMMDD}_{HHMM}_edit.png \
  --retry 3

curl -s http://127.0.0.1:36677/upload -F "files=@/tmp/gfishimage_{YYYYMMDD}_{HHMM}_edit.png"
```

---

## 用户追加修改

- "线条再粗一点" → 提示词加 `thicker strokes, bolder outlines`
- "换个颜色" → 修改 Colors 部分
- "竖版" → 换 `9:16`
- "当封面用" → 换 `21:9`
- "换个主题" → 重新构建提示词
- "重新上传" → 用已有的本地文件重新跑 PicGo

---

## 注意事项

- 本地文件是临时态，上传成功后必须清理
- PicGo 上传必须通过 Server API：`curl -s http://127.0.0.1:36677/upload -F "files=@<file>"`
- **PicGo Server 不可用时，不降级、不跳过，必须提示用户先配置并启动 PicGo Server**
- 依赖：`httpx`（gfishimage）、`picgo`（npm，Server 模式）
- API Key：复用 `~/.gfishimage/config.json`
- PicGo 上传失败时保留本地文件兜底
- 图床链接输出格式：`![](URL)`，不含描述文字
