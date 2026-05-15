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

### pic-upload
通过 PicGo Server 上传本地图片到图床，返回永久 CDN 链接。

**适用场景：**
- 上传截图或生成的图片获取永久链接
- 批量上传多张图片
- 将本地图片路径转换为 CDN 链接，用于 Markdown 或网页内容

**核心功能：**
- 通过 PicGo Server API 上传（localhost:36677）
- 支持 PNG、JPG、JPEG、GIF、WEBP、SVG、BMP 格式
- 支持单张和批量上传
- 返回可直接用于 Markdown 的 CDN 链接

### agent-init
为 Claude Code 初始化轻量项目协作骨架。生成 `CLAUDE.md` 入口文件及 `.claude/` 运行目录，包含 rules、memory、agents 及 hooks 配置。Codex 仅作为 Claude Code 临时调用的任务执行工具，不作为独立的骨架初始化目标。

**适用场景：**
- 新项目快速搭建 Claude Code 协作骨架
- 已有项目补齐缺失的规则、记忆或代理模板
- 团队项目结构标准化（Claude Code 工作流）

**核心功能：**
- 生成 `CLAUDE.md` + `.claude/`，包含 rules、memory、agents 及 `settings.json` hooks 配置
- 幂等执行：复用已有文件，仅补齐缺失部分
- 记忆模板：会话简报、项目进展跟踪、修正记录、观察笔记
- 代理模板：planner、executor、verifier（Markdown + YAML frontmatter）
- 可选 `docs-profile=engineering` 初始化工程文档骨架（架构/计划/任务）
- 提供 Python CLI 脚本（`scripts/init_agent.py`）自动化初始化

### GoCloudNativeBestPractices
Golang 云原生部署模式，用于容器化 Go 服务。补充 [samber/cc-skills-golang](https://github.com/samber/cc-skills-golang)（覆盖代码风格、错误处理、并发、测试等）的部署专属指导。

**适用场景：**
- 创建 Go 多阶段 Dockerfile（scratch/distroless）
- 为 Go 项目配置 Makefile
- 配置 Kubernetes 健康探针（`/healthz`、`/readyz`）
- 检查 Go 版本兼容性（1.20-1.26）

**核心功能：**
- 多阶段 Dockerfile 模板（distroless 镜像）
- Makefile 模板（build、test、lint、cover、docker）
- Kubernetes 存活/就绪探针模式
- Go 版本兼容矩阵与语法差异

**推荐搭配：** 如需全面的 Go 编码最佳实践（错误处理、并发、测试等），建议同时安装 [samber/cc-skills-golang](https://github.com/samber/cc-skills-golang)。

### proxy-domain-conflict-debugging
诊断和修复 VPN/代理设置与公司内部域名之间的冲突，特别是终端 HTTP/HTTPS/ALL_PROXY、NO_PROXY/no_proxy、macOS GUI 启动环境、Git 代理配置和 Go 模块设置导致私有 Git 或 Go 模块下载失败的情况。

**适用场景：**
- 修复公司私有域名的 Go 模块下载失败（EOF、unrecognized import path、`?go-get=1` 错误）
- 诊断 VPN/代理路由与内部 Git 仓库的冲突
- 配置 NO_PROXY、GOPRIVATE、GONOPROXY、GONOSUMDB 用于公司域名
- 修复 macOS IDE 代理环境变量继承问题
- 调试代理工具（如 Clash、Surge）的 Fake-IP DNS 范围（198.18.0.0/15）

**核心功能：**
- 只读诊断脚本，覆盖代理环境、Go 环境、Git 配置、macOS GUI 环境、DNS、curl 和 Go 模块下载
- NO_PROXY、GOPRIVATE、Git 主机特定代理覆盖、`launchctl setenv` 的分步修复模式
- Go 私有模块路由和故障解读参考指南

### golang-company-standards
公司 Go 编码规范 — 强制执行内部编码规范，涵盖代码风格、错误处理、命名、控制结构、函数设计、注释、依赖管理和代码检查。替代社区同类 skill（golang-code-style、golang-naming、golang-lint、golang-error-handling、golang-documentation、golang-testing）。

**适用场景：**
- 按公司编码规范编写 Go 代码
- 审查和修复 Go 代码使其符合公司规范
- 配置 golangci-lint 公司标准配置
- 新建 Go 项目时设置正确的编码约定

**核心功能：**
- 10 大规则类别：格式化、import、错误处理、注释、命名、控制结构、函数、测试、依赖管理、代码检查
- 必须/推荐/可选三级规则等级，边界清晰
- 完整的 golangci-lint 配置（25+ linters）可直接复制到项目
- 快速参考表，编码时可快速查阅规则

### golang-security
公司 Go 安全编码规范 — 涵盖内存安全、文件系统安全、命令注入防护、TLS通信安全、敏感数据保护、加密解密、输入校验、SQL注入防护、SSRF防护、模板注入、CORS、安全响应头、会话管理、CSRF防护、访问控制和并发安全。替代社区安全 skill（samber/cc-skills-golang golang-security、golang-safety）。

**适用场景：**
- 按公司安全规范编写 Go 代码
- Go 代码安全审计和审查
- 识别和修复安全漏洞（注入、XSS、SSRF 等）
- 正确配置 TLS、CSRF、CORS 和会话管理

**核心功能：**
- 11 个安全领域，必须/推荐两级规则等级
- 内存安全：slice 越界、nil 指针、整数溢出、make 长度校验、协程退出
- Web 安全：模板注入、CORS、安全响应头、响应编码
- 数据保护：禁止硬编码密钥、日志脱敏、加密存储、密钥管理
- SQL 安全：预编译语句、参数化查询、ORDER BY 白名单
- 并发安全：闭包循环变量、并发 map 写入、同步原语
- 完整的安全审查清单，支持结构化代码审计

## 安装方法

### 通过插件市场安装

首先，在 Claude Code 中添加此仓库为插件市场：
```
/plugin marketplace add gfishlab/happy-claude-skills
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
/plugin install pic-upload@happy-claude-skills-gxj
/plugin install agent-init@happy-claude-skills-gxj
/plugin install GoCloudNativeBestPractices@happy-claude-skills-gxj
/plugin install proxy-domain-conflict-debugging@happy-claude-skills-gxj
/plugin install golang-company-standards@happy-claude-skills-gxj
/plugin install golang-security@happy-claude-skills-gxj
```

### 通过 Skills CLI 安装

使用 [Vercel Labs Skills CLI](https://github.com/vercel-labs/skills)（`npx skills add`），支持 Claude Code、Cursor、Codex 等 40+ 种 Agent。

```bash
# 安装所有 skills
npx skills add gfishlab/happy-claude-skills

# 安装指定 skill
npx skills add gfishlab/happy-claude-skills --skill docx-format-replicator
npx skills add gfishlab/happy-claude-skills --skill video-processor
npx skills add gfishlab/happy-claude-skills --skill wechat-article-writer
npx skills add gfishlab/happy-claude-skills --skill browser
npx skills add gfishlab/happy-claude-skills --skill book-cover-generator
npx skills add gfishlab/happy-claude-skills --skill report-generator
npx skills add gfishlab/happy-claude-skills --skill markdown-helper
npx skills add gfishlab/happy-claude-skills --skill resume-review
npx skills add gfishlab/happy-claude-skills --skill pic-upload
npx skills add gfishlab/happy-claude-skills --skill agent-init
npx skills add gfishlab/happy-claude-skills --skill GoCloudNativeBestPractices
npx skills add gfishlab/happy-claude-skills --skill proxy-domain-conflict-debugging
npx skills add gfishlab/happy-claude-skills --skill golang-company-standards
npx skills add gfishlab/happy-claude-skills --skill golang-security

# 安装前先查看可用的 skills
npx skills add gfishlab/happy-claude-skills --list
```

### 本地开发安装

克隆仓库后，使用 `--plugin-dir` 参数：
```bash
git clone https://github.com/gfishlab/happy-claude-skills.git
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

> "为我的项目初始化 Claude Code 协作骨架，包含规则、记忆和代理模板"

> "为我的 Go 服务创建 Dockerfile"

> "为我的 Go 项目配置 Makefile"

> "配置 Kubernetes 健康探针"

> "诊断公司私有域名的 Go 模块下载失败（EOF 错误）"

> "按公司规范编写 Go 代码"

> "修复这段 Go 代码使其符合公司编码规范"

> "安全审计这个 Go 服务的漏洞"

> "审查我的 Go 代码是否存在 SQL 注入和命令注入"

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

### pic-upload
- [PicGo](https://molunerfinn.com/PicGo/) 并开启 Server 服务（默认端口 36677）

### agent-init
- Python 3.7+
- 无需额外依赖（使用内置模块）

### proxy-domain-conflict-debugging
- Bash 3.2+
- 无需额外依赖（使用标准系统工具：curl、dig、dscacheutil、launchctl、git、go）

### golang-company-standards
- Go 1.11+
- golangci-lint v2.6.2

```bash
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.6.2
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
│   └── pic-upload/
│       └── SKILL.md             # Skill 定义
│   └── agent-init/
│       ├── SKILL.md             # Skill 定义
│       ├── agents/              # Agent 配置
│       ├── references/          # 参考文档
│       ├── scripts/             # 初始化脚本
│       └── templates/           # 骨架模板
│   └── GoCloudNativeBestPractices/
│       ├── SKILL.md             # Skill 定义
│       └── references/          # Go 模式与版本兼容指南
│   └── proxy-domain-conflict-debugging/
│       ├── SKILL.md             # Skill 定义
│       ├── agents/              # Agent 配置
│       ├── references/          # Go 私有模块参考
│       └── scripts/             # 诊断脚本
│   └── golang-company-standards/
│       ├── SKILL.md             # Skill 定义
│       └── references/          # golangci-lint 配置
│   └── golang-security/
│       ├── SKILL.md             # Skill 定义
│       └── references/          # 安全规范参考文档（11 个领域）
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
