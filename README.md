[English](README.md) | [中文](README.zh-CN.md)

# Happy Claude Skills

A collection of practical skill plugins designed for Claude Code.

## Included Skills

### docx-format-replicator
Extract formatting from existing Word documents and generate new documents with the same format.

**Use Cases:**
- Corporate document template replication
- Batch generation of consistently formatted documents
- Technical specification document series
- Standardized documentation like development task sheets

### video-processor
Download and process videos from YouTube and other platforms. Supports video download, audio extraction, format conversion, and Whisper transcription.

**Use Cases:**
- Download videos from YouTube and other platforms
- Extract audio from video files
- Convert videos to MP4/WebM formats
- Transcribe audio/video to text using Whisper

### wechat-article-writer
Automated WeChat article writing workflow with 4 steps: research, writing, title generation, and formatting optimization.

**Use Cases:**
- Write WeChat official account articles
- Generate viral headlines
- Content creation for self-media
- Article formatting and optimization

### browser
Browser automation using Chrome DevTools Protocol. Start Chrome, navigate pages, execute JavaScript, take screenshots, and interactively pick DOM elements.

**Use Cases:**
- Web scraping with authenticated sessions
- Visual regression testing
- DOM inspection and data extraction
- Screenshot capture for documentation

### book-cover-generator
AI-powered book and movie poster generator using Midjourney V5.0 with 5000+ visual style combinations.

**Use Cases:**
- Generate book cover posters
- Create movie promotional posters
- Visual showcase for literary works
- Book recommendation posters for knowledge bloggers

**Core Features:**
- Automatic extraction of work information (themes, quotes, insights, characters, timeline)
- Intelligent visual style adaptation (color schemes, patterns, calligraphy styles)
- Chinese font optimization (Source Han Serif for clarity)
- Support for both portrait (2:3) and landscape (16:9) ratios

### report-generator
Automated weekly report generator based on git commit history. Creates structured work summaries for team communication.

**Use Cases:**
- Generate weekly work reports
- Team progress updates
- Project milestone summaries
- Enterprise OA system reporting (WeChat Work, DingTalk)

**Core Features:**
- Automatic extraction of this week's git commits
- Intelligently summarizes commits into 10 key items
- Each item is 20-30 characters
- Ordered list format (1, 2, 3...)
- Filters meaningless commits (merge, wip, tmp)
- Deduplicates and categorizes by module

### markdown-helper
Markdown document writing assistant with PlantUML/Mermaid diagram generation, format checking, and table of contents creation.

**Use Cases:**
- Generate UML diagrams (use case diagrams, sequence diagrams, class diagrams, activity diagrams, swimlane diagrams)
- Generate flowcharts, mindmaps, and Gantt charts
- Auto-convert PlantUML code to PNG images
- Check and fix Markdown format issues
- Generate table of contents automatically

**Supported Chart Types:**
- **PlantUML (default)**: Use case diagram, sequence diagram, class diagram, activity diagram, state diagram, component diagram, deployment diagram, swimlane diagram
- **Mermaid (optional)**: Flowchart, sequence diagram, mindmap, Gantt chart, ER diagram, state diagram

**Core Features:**
- PlantUML code generation with standard UML syntax
- Mermaid code generation for quick diagrams
- Automatic PNG conversion via online service (no CLI tools needed)
- Format validation (header indentation, spacing, numbering)
- Table of contents generation with anchor links
- Image path management and naming conventions
- Tool selection guide (PlantUML vs Mermaid)

**Tool Selection:**
- Use **PlantUML** for: Standard UML diagrams, formal documentation, enterprise documents
- Use **Mermaid** for: GitHub/GitLab docs, quick flowcharts, mindmaps
- Both tools can be used together in the same project

### resume-review
Multi-expert resume review panel with three senior experts (HR, Tech Interviewer, Senior Engineer) independently evaluating your resume from different perspectives.

**Use Cases:**
- Comprehensive resume review and scoring
- Pre-interview resume optimization
- Identify strengths and weaknesses from multiple expert viewpoints
- Benchmark against big-tech (h) or SMB (m) standards

**Core Features:**
- Three independent expert perspectives (HR, Tech Interviewer, Senior Engineer)
- Dual calibration: `h` (big-tech P6-P7) or `m` (SMB mid-senior)
- Quantified scoring (each expert rates 1-10)
- Severity markers for issues (`[!]` important, `[i]` suggestion)
- Overall score with positioning feedback
- Top 3 priority improvement recommendations
- Flexible input: paste text, provide file path, or upload

### pic-upload
Upload local image files to image hosting via PicGo Server and return permanent CDN URLs.

**Use Cases:**
- Upload screenshots or generated images to get permanent URLs
- Batch upload multiple images at once
- Convert local image paths to CDN links for markdown or web content

**Core Features:**
- Uploads via PicGo Server API (localhost:36677)
- Supports PNG, JPG, JPEG, GIF, WEBP, SVG, BMP
- Single and batch upload modes
- Returns CDN URLs ready for use in markdown

### agent-init
Lightweight project scaffolding for Claude Code. Initializes `CLAUDE.md` entry file and `.claude/` runtime directory with rules, memory, agents, and hook configuration. Codex is supported only as a task executor invoked by Claude Code, not as an independent scaffolding target.

**Use Cases:**
- Bootstrap a new project with Claude Code collaboration scaffolding
- Supplement existing projects with missing rules, memory, or agent templates
- Standardize team project structure for Claude Code workflows

**Core Features:**
- Generates `CLAUDE.md` + `.claude/` with rules, memory, agents, and `settings.json` hooks
- Idempotent: reuses existing files, only fills in missing parts
- Memory templates: session briefs, project progress tracking, corrections, observations
- Agent templates: planner, executor, verifier (Markdown with YAML frontmatter)
- Optional `docs-profile=engineering` for architecture/plan/task document scaffolding
- Python CLI script (`scripts/init_agent.py`) for automated initialization

### GoCloudNativeBestPractices
Golang cloud-native deployment patterns for containerized Go services. Complements [samber/cc-skills-golang](https://github.com/samber/cc-skills-golang) (which covers code style, error handling, concurrency, testing, etc.) with deployment-specific guidance.

**Use Cases:**
- Create multi-stage Dockerfile for Go (scratch/distroless)
- Set up Makefile for Go projects
- Configure Kubernetes health probes (`/healthz`, `/readyz`)
- Check Go version compatibility (1.20-1.26)

**Core Features:**
- Multi-stage Dockerfile templates with distroless images
- Makefile with build, test, lint, cover, docker targets
- Kubernetes liveness/readiness probe patterns
- Go version compatibility matrix and syntax gates

**Recommended companion:** For comprehensive Go coding best practices (error handling, concurrency, testing, etc.), consider also installing [samber/cc-skills-golang](https://github.com/samber/cc-skills-golang).

### proxy-domain-conflict-debugging
Diagnose and fix conflicts between VPN/proxy settings and internal company domains, especially when terminal HTTP/HTTPS/ALL_PROXY, NO_PROXY/no_proxy, macOS GUI launch environment, Git proxy config, and Go module settings cause private Git or Go module downloads to fail.

**Use Cases:**
- Fix Go module download failures for private company domains (EOF, unrecognized import path, `?go-get=1` errors)
- Diagnose VPN/proxy routing conflicts with internal Git repositories
- Configure NO_PROXY, GOPRIVATE, GONOPROXY, GONOSUMDB for company domains
- Fix macOS IDE proxy environment inheritance issues
- Debug fake-IP DNS ranges (198.18.0.0/15) from proxy tools like Clash or Surge

**Core Features:**
- Read-only diagnostic script covering proxy env, Go env, Git config, macOS GUI env, DNS, curl, and Go module download
- Step-by-step fix patterns for NO_PROXY, GOPRIVATE, Git host-specific proxy overrides, and `launchctl setenv`
- Reference guide for Go private module routing and failure interpretation

### golang-company-standards
Company Go coding standards — enforces internal coding specification covering code style, error handling, naming, control structures, function design, comments, dependency management, and linting. Supersedes overlapping community skills (golang-code-style, golang-naming, golang-lint, golang-error-handling, golang-documentation, golang-testing).

**Use Cases:**
- Write Go code following company coding standards
- Review and fix Go code to meet company specification
- Configure golangci-lint with company standard config
- Set up new Go projects with proper conventions

**Core Features:**
- 10 rule categories: formatting, imports, error handling, comments, naming, control structures, functions, testing, dependency management, linting
- Mandatory/preferable/optional rule levels with clear boundaries
- Full golangci-lint configuration (25+ linters) as a copyable reference file
- Quick reference table for fast rule lookup during coding

## Installation

### Install via Plugin Marketplace

First, add this repository as a plugin marketplace in Claude Code:
```
/plugin marketplace add gfishlab/happy-claude-skills
```

Then install the skills you need:
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
```

### Install via Skills CLI

Using [Vercel Labs Skills CLI](https://github.com/vercel-labs/skills) (`npx skills add`), supports Claude Code, Cursor, Codex and 40+ other agents.

```bash
# Install all skills
npx skills add gfishlab/happy-claude-skills

# Install a specific skill
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

# List available skills before installing
npx skills add gfishlab/happy-claude-skills --list
```

### Local Development Installation

After cloning the repository, use the `--plugin-dir` parameter:
```bash
git clone https://github.com/gfishlab/happy-claude-skills.git
claude --plugin-dir /path/to/happy-claude-skills
```

## Usage

After installation, simply describe your needs in Claude Code:

> "I have a document template and need to generate 5 new documents with the same format"

> "Download this YouTube video and transcribe it to text"

> "Help me write a WeChat article about AI programming tips"

> "Scrape the product information from this webpage"

> "Generate a book cover poster for 'The Three-Body Problem'"

> "Generate a weekly report"

> "Generate a user login flowchart"

> "Create a system architecture sequence diagram"

> "Check the markdown format and fix issues"

> "Review my resume and give me a score"

> "Initialize my project for Claude Code with rules, memory and agents"

> "Create a Dockerfile for my Go service"

> "Set up a Makefile for my Go project"

> "Configure Kubernetes health probes for my Go service"

> "Diagnose why my Go module download fails with EOF for company private domain"

> "Write Go code following our company standards"

> "Fix this Go code to meet our coding specification"

Claude will automatically identify and invoke the appropriate skill.

## Dependencies

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
- No additional dependencies (uses built-in modules)

**PlantUML (default):**
```bash
# No installation needed - uses online service
# Script: scripts/plantuml-to-png.js
```

**Mermaid (optional):**
```bash
# Only if you need to convert Mermaid to PNG
npm install -g @mermaid-js/mermaid-cli@10.9.0
npm install puppeteer@19.11.1
npx puppeteer browsers install chrome
```

### pic-upload
- [PicGo](https://molunerfinn.com/PicGo/) with Server enabled (default port 36677)

### agent-init
- Python 3.7+
- No additional dependencies (uses built-in modules)

### proxy-domain-conflict-debugging
- Bash 3.2+
- No additional dependencies (uses standard system tools: curl, dig, dscacheutil, launchctl, git, go)

### golang-company-standards
- Go 1.11+
- golangci-lint v2.6.2

```bash
curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/HEAD/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.6.2
```

## Project Structure

```
happy-claude-skills/
├── .claude-plugin/
│   └── marketplace.json         # Marketplace configuration
├── skills/
│   ├── docx-format-replicator/
│   │   ├── SKILL.md             # Skill definition
│   │   ├── scripts/             # Python scripts
│   │   ├── assets/              # Example files
│   │   └── references/          # Reference docs
│   ├── video-processor/
│   │   ├── SKILL.md             # Skill definition
│   │   └── scripts/             # Python scripts
│   ├── wechat-article-writer/
│   │   └── SKILL.md             # Skill definition
│   ├── browser/
│   │   ├── SKILL.md             # Skill definition
│   │   ├── package.json         # Node.js dependencies
│   │   └── scripts/             # Node.js scripts
│   ├── book-cover-generator/
│   │   └── SKILL.md             # Skill definition
│   ├── report-generator/
│   │   └── SKILL.md             # Skill definition
│   └── markdown-helper/
│       └── SKILL.md             # Skill definition
│   └── resume-review/
│       └── SKILL.md             # Skill definition
│   └── pic-upload/
│       └── SKILL.md             # Skill definition
│   └── agent-init/
│       ├── SKILL.md             # Skill definition
│       ├── agents/              # Agent configs
│       ├── references/          # Reference docs
│       ├── scripts/             # Init script
│       └── templates/           # Scaffold templates
│   └── GoCloudNativeBestPractices/
│       ├── SKILL.md             # Skill definition
│       └── references/          # Go patterns & version compat guides
│   └── proxy-domain-conflict-debugging/
│       ├── SKILL.md             # Skill definition
│       ├── agents/              # Agent configs
│       ├── references/          # Go private module reference
│       └── scripts/             # Diagnostic script
│   └── golang-company-standards/
│       ├── SKILL.md             # Skill definition
│       └── references/          # golangci-lint config
├── README.md
└── LICENSE
```

## Acknowledgments

This repository is forked from [iamzhihuix/happy-claude-skills](https://github.com/iamzhihuix/happy-claude-skills). Special thanks to the original author for creating this wonderful collection of Claude Code skills.

- **video-processor** skill is adapted from [claude-code-hooks-multi-agent-observability](https://github.com/disler/claude-code-hooks-multi-agent-observability) by [@disler](https://github.com/disler)
- **browser** skill is based on [Mario Zechner](https://mariozechner.at)'s article [What if you don't need MCP?](https://mariozechner.at/posts/2025-11-02-what-if-you-dont-need-mcp/) ([GitHub](https://github.com/badlogic/browser-tools)), adapted from [Factory.ai](https://docs.factory.ai/guides/skills/browser)

## Contributing

Issues and Pull Requests are welcome!

## License

MIT License
