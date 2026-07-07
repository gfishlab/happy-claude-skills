#!/usr/bin/env bash
#
# update_skills.sh — 更新全局 skills（常规 skill + well-known skill），并顺带更新常见 CLI
#
# 用法:
#   update_skills.sh [额外agent ...]
#   update_skills.sh --agent opencode,cursor
#   update_skills.sh opencode cursor
#   update_skills.sh --no-cli          # 只更新 skill，不更新 CLI
#
# 逻辑:
#   1) npx skills check -g -y   —— 更新可自动检测的常规全局 skill
#   2) 从 check 输出解析出所有 well-known skill 的 add URL，
#      用 -a 显式指定 agent 重新 add（避免 PromptScript 等无关 agent 的噪音）
#   3) 若常规 skill 无更新，明确提示；给出 skill 更新汇总
#   4) 默认再调用同目录 update_clis.sh 更新常见 CLI；传 --no-cli 可跳过
#
# 默认 agent（skills 工具的有效标识；Kiro 统一为 kiro-cli，不存在独立的 "kiro"）:
#   claude-code codex kiro-cli
# 注意: skills 的 -a 用【空格】分隔多个 agent，逗号会被当成单个无效 agent。
# 额外 agent（如 opencode）通过参数追加（逗号或空格皆可，脚本会归一化）。

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_AGENTS=(claude-code codex kiro-cli)

# ---- 解析参数：额外 agent（"--agent a,b" / "-a a,b" / 裸位置参数）+ --no-cli ----
EXTRA_AGENTS=()
RUN_CLI=1
_add_agents() {                # 把逗号或空格分隔的字符串拆入 EXTRA_AGENTS
  local raw="${1//,/ }"
  local a
  for a in $raw; do
    [ -n "$a" ] && EXTRA_AGENTS+=("$a")
  done
}
while [ $# -gt 0 ]; do
  case "$1" in
    --no-cli|--skills-only) RUN_CLI=0 ;;
    -a|--agent)             shift; [ $# -gt 0 ] && _add_agents "$1" ;;
    -a=*|--agent=*)         _add_agents "${1#*=}" ;;
    *)                      _add_agents "$1" ;;
  esac
  shift
done

# 合并默认与额外 agent（兼容 bash 3.2 空数组展开）
AGENTS=("${DEFAULT_AGENTS[@]}" ${EXTRA_AGENTS[@]+"${EXTRA_AGENTS[@]}"})

echo "════════════════════════════════════════════════════════"
echo " 全局 skills 更新"
echo " 目标 agent: ${AGENTS[*]}"
echo "════════════════════════════════════════════════════════"

# ---- 步骤 1: 更新常规全局 skill（可自动检测的）----
echo
echo "▶ [1/2] 检查并更新常规全局 skill (npx skills check -g -y) ..."
CHECK_OUT="$(npx skills check -g -y 2>&1)"
echo "$CHECK_OUT"

# 解析 "Found N global update(s)"（无匹配则视为 0）
FOUND="$(printf '%s\n' "$CHECK_OUT" \
  | grep -oE 'Found [0-9]+ global update' \
  | grep -oE '[0-9]+' | head -1)"
FOUND="${FOUND:-0}"

# ---- 步骤 2: 重新 add well-known skill（check 无法就地更新的，需重新拉取）----
# 从 check 输出里解析所有 "npx skills add <URL> ..." 的 URL，去重
# 用 while-read 填充数组，兼容 macOS 自带 bash 3.2（无 mapfile）
WK_URLS=()
while IFS= read -r _u; do
  [ -n "$_u" ] && WK_URLS+=("$_u")
done < <(printf '%s\n' "$CHECK_OUT" \
  | grep -oE 'npx skills add https?://[^ ]+' \
  | grep -oE 'https?://[^ ]+' \
  | sort -u)

echo
WK_COUNT=0
if [ "${#WK_URLS[@]}" -eq 0 ]; then
  echo "▶ [2/2] 无待重新 add 的 well-known skill（已随上一步 check 一并核对），跳过。"
else
  echo "▶ [2/2] 重新 add well-known skill，共 ${#WK_URLS[@]} 个来源，指定 agent 避免无关噪音 ..."
  for url in "${WK_URLS[@]}"; do
    echo "  • $url"
    if npx skills add "$url" -g -y -a "${AGENTS[@]}" >/dev/null 2>&1; then
      echo "    ✓ 已刷新"
      WK_COUNT=$((WK_COUNT + 1))
    else
      echo "    ✗ 失败: $url"
    fi
  done
fi

# ---- skill 汇总 ----
echo
echo "════════════════════════════════════════════════════════"
if [ "$FOUND" = "0" ] && [ "$WK_COUNT" -eq 0 ]; then
  echo " ✅ 没有需要更新的 skill。"
elif [ "$FOUND" = "0" ]; then
  echo " ✅ 常规全局 skill 无需更新；已刷新 $WK_COUNT 个 well-known skill 来源。"
else
  echo " ✅ 已更新 $FOUND 个常规全局 skill；已刷新 $WK_COUNT 个 well-known skill 来源。"
fi
echo "════════════════════════════════════════════════════════"

# ---- 步骤 3: 顺带更新常见 CLI（可用 --no-cli 关闭）----
if [ "$RUN_CLI" -eq 1 ]; then
  echo
  if [ -f "$SCRIPT_DIR/update_clis.sh" ]; then
    bash "$SCRIPT_DIR/update_clis.sh"
  else
    echo "⚠ 未找到 $SCRIPT_DIR/update_clis.sh，跳过 CLI 更新。"
  fi
fi

echo
echo "全局更新结束。"
