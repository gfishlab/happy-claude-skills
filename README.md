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

## Installation

### Install via Plugin Marketplace

First, add this repository as a plugin marketplace in Claude Code:
```
/plugin marketplace add gxj1134506645/happy-claude-skills
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
```

### Install via Skills CLI

Using [Vercel Labs Skills CLI](https://github.com/vercel-labs/skills) (`npx skills add`), supports Claude Code, Cursor, Codex and 40+ other agents.

```bash
# Install all skills to Claude Code globally
npx skills add gxj1134506645/happy-claude-skills -g -a claude-code -y

# Install a specific skill
npx skills add gxj1134506645/happy-claude-skills --skill docx-format-replicator -g -a claude-code -y
npx skills add gxj1134506645/happy-claude-skills --skill video-processor -g -a claude-code -y
npx skills add gxj1134506645/happy-claude-skills --skill wechat-article-writer -g -a claude-code -y
npx skills add gxj1134506645/happy-claude-skills --skill browser -g -a claude-code -y
npx skills add gxj1134506645/happy-claude-skills --skill book-cover-generator -g -a claude-code -y
npx skills add gxj1134506645/happy-claude-skills --skill report-generator -g -a claude-code -y
npx skills add gxj1134506645/happy-claude-skills --skill markdown-helper -g -a claude-code -y
npx skills add gxj1134506645/happy-claude-skills --skill resume-review -g -a claude-code -y

# List available skills before installing
npx skills add gxj1134506645/happy-claude-skills --list
```

### Local Development Installation

After cloning the repository, use the `--plugin-dir` parameter:
```bash
git clone https://github.com/gxj1134506645/happy-claude-skills.git
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
