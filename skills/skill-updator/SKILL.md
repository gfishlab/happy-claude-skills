---
name: skill-updator
description: "更新本机全局安装的 skills，并顺带更新常见 CLI 工具。当用户说『更新 skills』『更新全部 skill』『更新全局 skill』『升级 skills』『skill 有没有新版本』『把 skill 更到最新』『更新 cli』『升级 cli』，或直接提到 skill-updator / npx skills check / npx skills update 时使用。默认用 npx skills check -g 更新可自动检测的常规全局 skill，并自动解析出 well-known skill 一并更新；随后顺带更新常见 CLI（npm 全局包、brew formula、pipx 应用等）。默认只更新到 agent claude-code、codex、kiro-cli；用户可额外追加其它 agent（如 opencode、cursor）。不负责创建 skill（走 skill-creator）、也不负责按项目粒度更新。"
---

# skill-updator

一键更新本机**全局** skills 与常见 CLI 工具，屏蔽 `skills` 工具默认向所有 agent 安装时产生的无关噪音（如 PromptScript 报错）。

## 何时用

- 用户要求更新 / 升级全局 skills。
- 用户想把 well-known skill 更到最新。
- 用户想顺带更新常见 CLI（npm 全局包、brew formula、pipx 应用等）。

## 快速开始

运行封装脚本（默认 agent = `claude-code,codex,kiro-cli`，并顺带更新 CLI）：

```bash
bash scripts/update_skills.sh
```

追加额外 agent（裸参数或 `--agent`，都可，逗号或空格分隔）：

```bash
bash scripts/update_skills.sh opencode           # 追加 opencode
bash scripts/update_skills.sh opencode cursor     # 追加多个
bash scripts/update_skills.sh --agent opencode,cursor
```

只更新 skill、不动 CLI：

```bash
bash scripts/update_skills.sh --no-cli
```

只更新 CLI（不动 skill）：

```bash
bash scripts/update_clis.sh                 # 更新已装的；未装的仅 warn + 列清单
bash scripts/update_clis.sh --install-all   # 顺带安装所有「可自动安装」的缺失工具
bash scripts/update_clis.sh --install=1,3   # 只安装未安装清单里第 1、3 项
```

## 脚本做了什么

`update_skills.sh`（主入口）：

1. `npx skills check -g -y` —— 更新可自动检测的常规全局 skill，并解析 `Found N global update(s)`。同一步也会核对所有 well-known skill。
2. 从 check 输出中自动提取仍需**重新 add** 的 well-known skill 的 `npx skills add <URL>` 命令，对每个 URL 用 `-a <agents>` 重新 add。显式指定 agent 是关键——可避免向 PromptScript 等本机未使用、且不支持全局安装的 agent 写入而报错。若 check 已把它们核对为最新，则此步显示「无待重新 add 的 well-known skill，跳过」——这**不代表没检查**，只代表没有待处理的更新。
3. 给出 skill 更新汇总。
4. 默认调用同目录 `update_clis.sh` 顺带更新常见 CLI；传 `--no-cli`（或 `--skills-only`）可跳过。

`update_clis.sh`（可单独运行）覆盖五类来源，仅在检测到有新版时才更新：

- **npm 全局包**：用 `npm install -g <pkg>@latest` 更新。
- **brew formula**：`brew outdated` 判断后 `brew upgrade`。
- **pipx 应用**：`pipx upgrade`。
- **自更新型 CLI**：如 `uv`（`uv self update`），调用其内建自更新命令（幂等）。
- **手动安装的二进制**：无包管理器托管，**仅检测并提示更新方式，不自动改动**。

> 脚本自带的工具清单只是**通用示例**（codex、gh、helm、uv、jira-cli 等公开工具）。请按自己的实际环境在脚本顶部可配置区增删要跟踪的 CLI。

> **通用化 / 跨机使用**：配置里列出但本地未安装的工具，不静默跳过，而是发出 ⚠ 警告并在结尾汇总成「本地未安装清单」——可自动安装的(npm/brew/pipx)带编号与安装命令，需手动的(自更新型/手动二进制)给出提示。默认**不擅自安装**：交互式终端(TTY)下会提示输入编号选择安装；被 agent/管道非交互调用时只打印清单；也可用 `--install-all` 或 `--install=1,3` 显式安装。若某台机器缺 `npm`/`brew`/`pipx` 本身，脚本会提示先装对应包管理器并把相关工具列入手动清单。

### 新增要跟踪的 CLI

直接编辑 `scripts/update_clis.sh` 顶部可配置区的数组：

- `NPM_PKGS`：npm 全局包名（如 `@scope/pkg`）。
- `BREW_FORMULAE`：brew formula 名（注意是 formula 名而非二进制名）。
- `PIPX_PKGS`：pipx 包名（注意是包名而非命令名）。
- `SELF_UPDATE_TOOLS`：自带升级命令的 CLI，格式 `"命令名|自更新命令"`（如 `"uv|uv self update"`）。
- `MANUAL_HINTS`：手动安装的 CLI，格式 `"命令名|更新提示"`，只提示不自动更新。

## 关键约定（非直觉，务必遵守）

- **agent 标识只认 `kiro-cli`**，`skills` 工具中**不存在独立的 `kiro`**（传 `-a kiro` 会报 `Invalid agents: kiro`）。默认三件套即 `claude-code codex kiro-cli`。
- **`skills` 的 `-a` 用【空格】分隔多个 agent**（如 `-a claude-code codex kiro-cli`）；写成逗号 `-a claude-code,codex,kiro-cli` 会被当成单个无效 agent 而报错。脚本对外允许逗号/空格输入并自动归一化，但底层调用一律用空格。
- **well-known skill 通常已在 `npx skills check` 阶段一并核对**；只有 check 明确吐出 `npx skills add <URL>` 建议行时，才需要用该命令重新拉取。脚本已自动发现这些 URL，无需硬编码。
- **务必用 `-a` 指定 agent**再 add well-known skill；否则 `skills add` 会尝试写入其内置支持的全部 agent，其中 PromptScript 不支持全局安装，会每次刷出无意义的 `Failed to install` 报错。
- 全局 skill 实体位于 `~/.agents/skills/`，`~/.kiro/skills` 是指向它的 symlink；该目录非 git 仓库，无需 git 操作。
- **CLI 更新会改动本机已安装的工具**（npm / brew），属中等风险操作；脚本仅在检测到有新版时才动手，已最新则跳过。

## 有效 agent 标识（供追加参考）

常用：`claude-code`、`codex`、`kiro-cli`、`opencode`、`cursor`、`gemini-cli`、`amp`、`windsurf`、`zed`、`cline`、`roo`、`kilo`。传入无效标识时 `skills` 会打印 `Valid agents: ...` 完整清单。
