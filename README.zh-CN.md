[English](README.md) | [中文](README.zh-CN.md)

# Happy Claude Skills

一组为 Claude Code 设计的实用技能插件。

## 包含的 Skills

### docx-format-replicator
从现有 Word 文档提取格式，并用相同格式生成新文档。

**适用场景：**
- 企业文档模板复制
- 批量生成格式一致的文档
- 技术规范文档系列
- 研制任务书等标准化文档

### video-processor
从 YouTube 等平台下载和处理视频。支持视频下载、音频提取、格式转换和 Whisper 语音转文字。

**适用场景：**
- 从 YouTube 等平台下载视频
- 从视频文件中提取音频
- 将视频转换为 MP4/WebM 格式
- 使用 Whisper 将音频/视频转录为文字

### wechat-article-writer
公众号文章自动化写作流程，4 步完成高质量文章：搜索资料、撰写文章、生成标题、排版优化。

**适用场景：**
- 撰写微信公众号文章
- 生成爆款标题
- 自媒体内容创作
- 文章排版优化

### browser
基于 Chrome DevTools Protocol 的浏览器自动化工具。启动 Chrome、导航页面、执行 JavaScript、截图、可视化选择 DOM 元素。

**适用场景：**
- 带登录状态的网页爬虫
- 视觉回归测试
- DOM 检查和数据提取
- 截图用于文档

### book-cover-generator
AI驱动的图书/电影海报生成器，基于Midjourney V5.0稳定版Prompt，支持5000+种视觉风格组合。

**适用场景：**
- 生成书籍封面海报
- 制作电影宣传海报
- 文学作品可视化展示
- 知识博主书单推荐

**核心功能：**
- 自动提取作品信息（主题、语录、观点、人物、时间线）
- 智能适配视觉风格（配色、纹样、书法）
- 中文字体优化（思源宋体，确保清晰度）
- 支持竖版(2:3)和横版(16:9)两种比例

### report-generator
基于git提交记录的自动化周报生成器，创建结构化的工作总结用于团队汇报。

**适用场景：**
- 生成周工作汇报
- 团队进度同步
- 项目里程碑总结
- 企业OA系统汇报（企业微信、钉钉）

**核心功能：**
- 自动提取本周git提交记录
- 智能汇总为10条关键内容
- 每条20-30字，精简准确
- 阿拉伯数字有序排序（1、2、3...）
- 过滤无意义提交（merge、wip、tmp）
- 去重并按模块分类

### markdown-helper
Markdown文档编写辅助工具，支持PlantUML/Mermaid图表生成、格式检查和目录创建。

**适用场景：**
- 生成UML图表（用例图、时序图、类图、活动图、泳道图）
- 生成流程图、思维导图、甘特图
- 自动将PlantUML代码转换为PNG图片
- 检查并修复Markdown格式问题
- 自动生成目录

**支持的图表类型：**
- **PlantUML（默认）**：用例图、时序图、类图、活动图、状态图、组件图、部署图、泳道图
- **Mermaid（可选）**：流程图、时序图、思维导图、甘特图、ER图、状态图

**核心功能：**
- PlantUML代码生成，符合标准UML语法
- Mermaid代码生成，适合快速绘图
- 自动转换为PNG图片（通过在线服务，无需CLI工具）
- 格式验证（标题缩进、空行、编号）
- 生成带锚点链接的目录
- 图片路径管理和命名规范
- 工具选择指南（PlantUML vs Mermaid）

**工具选择：**
- 使用 **PlantUML**：标准UML图、正式文档、企业级文档
- 使用 **Mermaid**：GitHub/GitLab文档、快速流程图、思维导图
- 两种工具可以在同一项目中混用

### resume-review
多专家简历评审面板，三位资深专家（HR、技术面试官、资深工程师）从不同角度独立评审简历。

**适用场景：**
- 全面简历评审与打分
- 面试前简历优化
- 从多专家视角发现优劣势
- 对标大厂（h）或中小厂（m）标准

**核心功能：**
- 三位专家独立评审（HR、技术面试官、高级工程师）
- 双档校准：`h`（大厂P6-P7标准）/ `m`（中小厂中高级标准）
- 量化评分（每位专家1-10分）
- 问题严重性标记（`[!]` 重要、`[i]` 建议）
- 综合评分与定位反馈
- Top 3 优先改进建议
- 灵活输入：粘贴文本、提供文件路径或上传

## 安装方法

### 通过插件市场安装

首先，在 Claude Code 中添加此仓库为插件市场：
```
/plugin marketplace add gxj1134506645/happy-claude-skills
```

然后安装你需要的 skills：
```
/plugin install docx-format-replicator@happy-claude-skills-gxj
/plugin install video-processor@happy-claude-skills-gxj
/plugin install wechat-article-writer@happy-claude-skills-gxj
/plugin install browser@happy-claude-skills-gxj
/plugin install book-cover-generator@happy-claude-skills-gxj
/plugin install report-generator@happy-claude-skills-gxj
/plugin install markdown-helper@happy-claude-skills-gxj
/plugin install resume-review@happy-claude-skills-gxj
```

### 通过 Skills CLI 安装

使用 [Vercel Labs Skills CLI](https://github.com/vercel-labs/skills)（`npx skills add`），支持 Claude Code、Cursor、Codex 等 40+ 种 Agent。

```bash
# 安装所有 skills
npx skills add gxj1134506645/happy-claude-skills

# 安装指定 skill
npx skills add gxj1134506645/happy-claude-skills --skill docx-format-replicator
npx skills add gxj1134506645/happy-claude-skills --skill video-processor
npx skills add gxj1134506645/happy-claude-skills --skill wechat-article-writer
npx skills add gxj1134506645/happy-claude-skills --skill browser
npx skills add gxj1134506645/happy-claude-skills --skill book-cover-generator
npx skills add gxj1134506645/happy-claude-skills --skill report-generator
npx skills add gxj1134506645/happy-claude-skills --skill markdown-helper
npx skills add gxj1134506645/happy-claude-skills --skill resume-review

# 安装前先查看可用的 skills
npx skills add gxj1134506645/happy-claude-skills --list
```

### 本地开发安装

克隆仓库后，使用 `--plugin-dir` 参数：
```bash
git clone https://github.com/gxj1134506645/happy-claude-skills.git
claude --plugin-dir /path/to/happy-claude-skills
```

## 使用方法

安装后，在 Claude Code 中直接描述您的需求：

> "我有一个研制任务书模板，需要用相同格式生成5份新文档"

> "下载这个 YouTube 视频并转录成文字"

> "帮我写一篇关于 AI 编程技巧的公众号文章"

> "抓取这个网页的产品信息"

> "生成《三体》的图书封面海报"

> "生成周报"

> "生成用户登录流程图"

> "创建系统架构时序图"

> "检查markdown格式并修复问题"

> "帮我评审一下简历并打分"

Claude 会自动识别并调用相应的 skill。

## 依赖

### docx-format-replicator
- Python 3.7+
- python-docx

```bash
pip install python-docx
```

### video-processor
- Python 3.7+
- yt-dlp
- FFmpeg
- openai-whisper

```bash
pip install yt-dlp openai-whisper
brew install ffmpeg  # macOS
```

### browser
- Node.js 18+
- puppeteer-core
- Google Chrome

```bash
npm install --prefix skills/browser
```

### markdown-helper
- Node.js 14+
- 无需额外依赖（使用内置模块）

**PlantUML（默认）：**
```bash
# 无需安装 - 使用在线服务
# 脚本：scripts/plantuml-to-png.js
```

**Mermaid（可选）：**
```bash
# 仅在需要将Mermaid转换为PNG时安装
npm install -g @mermaid-js/mermaid-cli@10.9.0
npm install puppeteer@19.11.1
npx puppeteer browsers install chrome
```

## 项目结构

```
happy-claude-skills/
├── .claude-plugin/
│   └── marketplace.json         # 市场配置
├── skills/
│   ├── docx-format-replicator/
│   │   ├── SKILL.md             # Skill 定义
│   │   ├── scripts/             # Python 脚本
│   │   ├── assets/              # 示例文件
│   │   └── references/          # 参考文档
│   ├── video-processor/
│   │   ├── SKILL.md             # Skill 定义
│   │   └── scripts/             # Python 脚本
│   ├── wechat-article-writer/
│   │   └── SKILL.md             # Skill 定义
│   ├── browser/
│   │   ├── SKILL.md             # Skill 定义
│   │   ├── package.json         # Node.js 依赖
│   │   └── scripts/             # Node.js 脚本
│   ├── book-cover-generator/
│   │   └── SKILL.md             # Skill 定义
│   ├── report-generator/
│   │   └── SKILL.md             # Skill 定义
│   └── markdown-helper/
│       └── SKILL.md             # Skill 定义
│   └── resume-review/
│       └── SKILL.md             # Skill 定义
├── README.md
└── LICENSE
```

## 鸣谢

本仓库 fork 自 [iamzhihuix/happy-claude-skills](https://github.com/iamzhihuix/happy-claude-skills)，特别感谢原作者创建了这个精彩的 Claude Code skills 集合。

- **video-processor** skill 改编自 [@disler](https://github.com/disler) 的 [claude-code-hooks-multi-agent-observability](https://github.com/disler/claude-code-hooks-multi-agent-observability) 项目
- **browser** skill 基于 [Mario Zechner](https://mariozechner.at) 的文章 [What if you don't need MCP?](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/) ([GitHub](https://github.com/badlogic/browser-tools))，整理自 [Factory.ai](https://docs.factory.ai/guides/skills/browser)

## 贡献

欢迎提交 Issue 和 Pull Request！

## 许可证

MIT License
