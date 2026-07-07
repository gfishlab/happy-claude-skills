#!/usr/bin/env bash
#
# update_clis.sh — 更新本机常见 CLI 工具（可单独运行，也被 update_skills.sh 顺带调用）
#
# 覆盖五类来源：
#   1) npm 全局包       —— 用 npm install -g <pkg>@latest 更新
#   2) brew formula     —— brew outdated 判断后 brew upgrade
#   3) pipx 应用        —— pipx upgrade
#   4) 自更新型 CLI     —— 如 uv(uv self update)，调用其内建自更新命令
#   5) 手动安装的二进制 —— 无包管理器托管，仅检测并提示更新方式，不自动改动
#
# 注意：下方可配置区列出的工具只是【通用示例】（codex、gh、helm、uv、jira-cli 等
#       公开工具）。请按自己的实际环境增删要跟踪的 CLI。
#
# 设计原则：
#   - 已安装且有新版 -> 更新；已安装且最新 -> 跳过；取不到最新版本(网络) -> 跳过。
#   - 【通用化】配置里列出但本地未安装的工具，不静默跳过，而是发出 ⚠ 警告并汇总成
#     「本地未安装清单」；可自动安装的(npm/brew/pipx)给出安装命令，由用户自行选择安装：
#       * 交互式终端(TTY)下会提示输入要安装的编号；
#       * 非交互(被 agent/管道调用)只打印清单，不擅自安装；
#       * 也可用 --install-all / --install=1,3 显式安装。
#
# 用法:
#   update_clis.sh                 # 更新已装的；未装的仅 warn + 列清单
#   update_clis.sh --install-all   # 顺带安装所有「可自动安装」的缺失工具
#   update_clis.sh --install=1,3   # 只安装清单中第 1、3 项

set -uo pipefail

# ---- 参数：是否安装缺失工具 ----
INSTALL_MODE=""      # "" | "all" | "1,3,..."
while [ $# -gt 0 ]; do
  case "$1" in
    --install-all)   INSTALL_MODE="all" ;;
    --install=*)     INSTALL_MODE="${1#*=}" ;;
    --install)       shift; [ $# -gt 0 ] && INSTALL_MODE="$1" ;;
    *)               echo "⚠ 未知参数已忽略: $1" ;;
  esac
  shift
done

# ==== 可配置区：新增 CLI 在这里加（以下均为通用公开示例，请按需增删）====
# npm 全局包（写包名即可）
NPM_PKGS=(
  "@openai/codex"                  # codex CLI（示例）
  # "@your-scope/your-cli"         # 在这里追加你自己的 npm 全局 CLI
)
# brew formula（写 formula 名，不是二进制名）
BREW_FORMULAE=(
  gh                               # GitHub CLI（示例）
  helm                             # Kubernetes Helm（示例）
  # your-formula                   # 在这里追加你自己的 brew formula
)
# pipx 应用（写 pipx 包名，不是命令名）
PIPX_PKGS=(
  # your-pipx-pkg                  # 在这里追加你自己的 pipx 包
)
# 自更新型 CLI（自带升级命令）。格式 "命令名|自更新命令|未安装时的安装提示(可选)"
SELF_UPDATE_TOOLS=(
  "uv|uv self update|curl -LsSf https://astral.sh/uv/install.sh | sh"   # uv / uvx（示例）
)
# 手动安装的 CLI：仅提示，不自动更新。格式 "命令名|更新/安装提示"
MANUAL_HINTS=(
  "jira|手动下载的二进制，请到 https://github.com/ankitpokhrel/jira-cli/releases 下载最新版覆盖（示例）"
)
# ====================================

echo "════════════════════════════════════════════════════════"
echo " 常见 CLI 更新"
echo "════════════════════════════════════════════════════════"

UPDATED=0
LATEST_CNT=0
# 缺失清单：可自动安装的 "标签|安装命令"
MISSING_AUTO=()
# 缺失清单：需手动处理的 "标签|提示"
MISSING_MANUAL=()

# ---- 1) npm 全局包 ----
echo
echo "▶ npm 全局 CLI ..."
if command -v npm >/dev/null 2>&1; then
  for pkg in ${NPM_PKGS[@]+"${NPM_PKGS[@]}"}; do
    cur="$(npm ls -g "$pkg" --depth=0 2>/dev/null \
      | grep -oE "$pkg@[0-9][0-9.]*" | sed "s#$pkg@##" | head -1)"
    if [ -z "$cur" ]; then
      echo "  ⚠ $pkg : 本地未安装"
      MISSING_AUTO+=("$pkg [npm]|npm install -g $pkg")
      continue
    fi
    latest="$(npm view "$pkg" version 2>/dev/null | tr -d '[:space:]')"
    if [ -z "$latest" ]; then
      echo "  • $pkg : 无法获取最新版本（网络？），跳过"
      continue
    fi
    if [ "$cur" = "$latest" ]; then
      echo "  • $pkg : $cur 已最新"
      LATEST_CNT=$((LATEST_CNT + 1))
    else
      echo "  • $pkg : $cur → $latest 更新中 ..."
      if npm install -g "$pkg@latest" >/dev/null 2>&1; then
        echo "    ✓ 已更新到 $latest"
        UPDATED=$((UPDATED + 1))
      else
        echo "    ✗ 更新失败"
      fi
    fi
  done
else
  echo "  ⚠ 未找到 npm —— 以下 npm 全局包无法检查/安装，请先装 Node.js/npm："
  for pkg in ${NPM_PKGS[@]+"${NPM_PKGS[@]}"}; do
    echo "      - $pkg"
    MISSING_MANUAL+=("$pkg [npm]|需先安装 Node.js/npm 后：npm install -g $pkg")
  done
fi

# ---- 2) brew formula ----
echo
echo "▶ brew CLI ..."
if command -v brew >/dev/null 2>&1; then
  for f in ${BREW_FORMULAE[@]+"${BREW_FORMULAE[@]}"}; do
    if ! brew list --versions "$f" >/dev/null 2>&1; then
      echo "  ⚠ $f : 本地未安装"
      MISSING_AUTO+=("$f [brew]|brew install $f")
      continue
    fi
    ver="$(brew list --versions "$f" 2>/dev/null | awk '{print $2}')"
    if brew outdated --formula "$f" 2>/dev/null | grep -q .; then
      echo "  • $f : $ver 有新版，升级中 ..."
      if brew upgrade "$f" >/dev/null 2>&1; then
        echo "    ✓ 已升级"
        UPDATED=$((UPDATED + 1))
      else
        echo "    ✗ 升级失败"
      fi
    else
      echo "  • $f : $ver 已最新"
      LATEST_CNT=$((LATEST_CNT + 1))
    fi
  done
else
  echo "  ⚠ 未找到 brew —— 以下 formula 无法检查/安装，请先装 Homebrew："
  for f in ${BREW_FORMULAE[@]+"${BREW_FORMULAE[@]}"}; do
    echo "      - $f"
    MISSING_MANUAL+=("$f [brew]|需先安装 Homebrew 后：brew install $f")
  done
fi

# ---- 3) pipx 应用 ----
echo
echo "▶ pipx CLI ..."
if command -v pipx >/dev/null 2>&1; then
  for pkg in ${PIPX_PKGS[@]+"${PIPX_PKGS[@]}"}; do
    if ! pipx list --short 2>/dev/null | grep -qE "^$pkg( |\$)"; then
      echo "  ⚠ $pkg : 本地未安装"
      MISSING_AUTO+=("$pkg [pipx]|pipx install $pkg")
      continue
    fi
    cur="$(pipx list --short 2>/dev/null | awk -v p="$pkg" '$1==p{print $2}')"
    out="$(pipx upgrade "$pkg" 2>&1)"
    if printf '%s' "$out" | grep -qi 'already at latest'; then
      echo "  • $pkg : $cur 已最新"
      LATEST_CNT=$((LATEST_CNT + 1))
    elif printf '%s' "$out" | grep -qiE 'upgrad'; then
      new="$(pipx list --short 2>/dev/null | awk -v p="$pkg" '$1==p{print $2}')"
      echo "  • $pkg : $cur → $new ✓ 已升级"
      UPDATED=$((UPDATED + 1))
    else
      echo "  • $pkg : 升级结果未知（$(printf '%s' "$out" | tail -1)）"
    fi
  done
else
  echo "  ⚠ 未找到 pipx —— 以下 pipx 应用无法检查/安装，请先装 pipx："
  for pkg in ${PIPX_PKGS[@]+"${PIPX_PKGS[@]}"}; do
    echo "      - $pkg"
    MISSING_MANUAL+=("$pkg [pipx]|需先安装 pipx 后：pipx install $pkg")
  done
fi

# ---- 4) 自更新型 CLI（调用其内建自更新命令）----
echo
echo "▶ 自更新型 CLI ..."
_su_shown=0
for entry in ${SELF_UPDATE_TOOLS[@]+"${SELF_UPDATE_TOOLS[@]}"}; do
  cmd="${entry%%|*}"; rest="${entry#*|}"
  updcmd="${rest%%|*}"; inst="${rest#*|}"
  [ "$inst" = "$rest" ] && inst=""           # 无第三段则安装提示为空
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "  ⚠ $cmd : 本地未安装（自更新型工具，不自动安装）"
    MISSING_MANUAL+=("$cmd [self]|${inst:-请按官网方式安装}")
    continue
  fi
  _su_shown=1
  out="$($updcmd 2>&1)"
  if printf '%s' "$out" | grep -qiE 'latest version|up to date|already'; then
    echo "  • $cmd : 已最新"
    LATEST_CNT=$((LATEST_CNT + 1))
  elif printf '%s' "$out" | grep -qiE 'upgrad|updated|success'; then
    echo "  • $cmd : ✓ 已更新"
    UPDATED=$((UPDATED + 1))
  else
    echo "  • $cmd : 已执行自更新（$(printf '%s' "$out" | tail -1)）"
  fi
done
[ "$_su_shown" -eq 0 ] && [ "${#SELF_UPDATE_TOOLS[@]}" -eq 0 ] && echo "  (无)"

# ---- 5) 手动安装：仅提示（已装则给更新提示；未装则计入缺失清单）----
echo
echo "▶ 手动安装的 CLI（不自动更新）..."
for entry in ${MANUAL_HINTS[@]+"${MANUAL_HINTS[@]}"}; do
  cmd="${entry%%|*}"
  hint="${entry#*|}"
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "  • $cmd : $hint"
  else
    echo "  ⚠ $cmd : 本地未安装"
    MISSING_MANUAL+=("$cmd [手动]|$hint")
  fi
done

# ---- 本地未安装清单 + 可选安装 ----
if [ "${#MISSING_AUTO[@]}" -gt 0 ] || [ "${#MISSING_MANUAL[@]}" -gt 0 ]; then
  echo
  echo "────────────────────────────────────────────────────────"
  echo " ⚠ 本地未安装清单（跨机使用时按需选择安装）"
  echo "────────────────────────────────────────────────────────"
  idx=0
  if [ "${#MISSING_AUTO[@]}" -gt 0 ]; then
    echo " 可自动安装："
    for e in "${MISSING_AUTO[@]}"; do
      idx=$((idx + 1))
      printf "  [%d] %-28s 安装: %s\n" "$idx" "${e%%|*}" "${e#*|}"
    done
  fi
  if [ "${#MISSING_MANUAL[@]}" -gt 0 ]; then
    echo " 需手动处理（不在自动安装范围）："
    for e in "${MISSING_MANUAL[@]}"; do
      printf "   -  %-28s %s\n" "${e%%|*}" "${e#*|}"
    done
  fi

  # 决定要安装哪些（参数优先；否则交互式终端提示；否则不安装）
  SEL=""
  if [ -n "$INSTALL_MODE" ]; then
    SEL="$INSTALL_MODE"
  elif [ -t 0 ] && [ "${#MISSING_AUTO[@]}" -gt 0 ]; then
    echo
    printf "选择现在要安装的编号(空格/逗号分隔, a=全部, 回车=跳过): "
    read -r SEL || SEL=""
  fi
  [ "$SEL" = "a" ] && SEL="all"

  if [ -n "$SEL" ] && [ "${#MISSING_AUTO[@]}" -gt 0 ]; then
    TO_INSTALL=()
    if [ "$SEL" = "all" ]; then
      i=1; while [ "$i" -le "${#MISSING_AUTO[@]}" ]; do TO_INSTALL+=("$i"); i=$((i + 1)); done
    else
      for n in ${SEL//,/ }; do
        case "$n" in *[!0-9]*|"") continue ;; esac
        TO_INSTALL+=("$n")
      done
    fi
    echo
    for n in "${TO_INSTALL[@]}"; do
      if [ "$n" -lt 1 ] || [ "$n" -gt "${#MISSING_AUTO[@]}" ]; then
        echo "  跳过无效编号: $n"; continue
      fi
      entry="${MISSING_AUTO[$((n - 1))]}"
      label="${entry%%|*}"; cmd="${entry#*|}"
      echo "  ▷ 安装 $label : $cmd"
      if eval "$cmd" >/dev/null 2>&1; then
        echo "    ✓ 已安装"; UPDATED=$((UPDATED + 1))
      else
        echo "    ✗ 安装失败"
      fi
    done
  elif [ -z "$INSTALL_MODE" ] && [ ! -t 0 ] && [ "${#MISSING_AUTO[@]}" -gt 0 ]; then
    echo
    echo "  提示：在交互式终端运行本脚本可按编号选择安装，"
    echo "        或用  bash update_clis.sh --install-all  /  --install=1,3  安装。"
  fi
fi

# ---- 汇总 ----
echo
echo "════════════════════════════════════════════════════════"
echo " ✅ CLI 更新结束：更新/安装 $UPDATED 个，已最新 $LATEST_CNT 个，本地未安装 $(( ${#MISSING_AUTO[@]} + ${#MISSING_MANUAL[@]} )) 个。"
echo "════════════════════════════════════════════════════════"
