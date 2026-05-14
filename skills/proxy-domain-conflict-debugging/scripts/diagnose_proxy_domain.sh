#!/usr/bin/env bash
set -u

domain="${1:-}"
module_dir="${2:-}"

if [[ -z "$domain" ]]; then
  echo "usage: diagnose_proxy_domain.sh <domain> [go-module-dir]" >&2
  exit 2
fi

echo "== domain =="
echo "$domain"
echo

echo "== terminal proxy env =="
env | grep -Ei '^(http_proxy|https_proxy|all_proxy|no_proxy|HTTP_PROXY|HTTPS_PROXY|ALL_PROXY|NO_PROXY)=' || true
echo

echo "== go env =="
if command -v go >/dev/null 2>&1; then
  go env GOPRIVATE GOPROXY GONOPROXY GONOSUMDB GOENV
else
  echo "go: not found"
fi
echo

echo "== git proxy config =="
if command -v git >/dev/null 2>&1; then
  git config --global --get-regexp 'http\..*proxy|https\..*proxy|url\..*insteadOf|credential' || true
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git config --local --get-regexp 'http\..*proxy|https\..*proxy|url\..*insteadOf|credential' || true
  fi
else
  echo "git: not found"
fi
echo

echo "== macOS GUI env =="
if command -v launchctl >/dev/null 2>&1; then
  printf 'NO_PROXY='; launchctl getenv NO_PROXY || true
  printf 'no_proxy='; launchctl getenv no_proxy || true
  printf 'HTTPS_PROXY='; launchctl getenv HTTPS_PROXY || true
else
  echo "launchctl: not found"
fi
echo

echo "== DNS =="
if command -v dscacheutil >/dev/null 2>&1; then
  dscacheutil -q host -a name "$domain" || true
fi
if command -v dig >/dev/null 2>&1; then
  dig +short "$domain" || true
fi
echo

echo "== curl discovery root =="
if command -v curl >/dev/null 2>&1; then
  curl -I -L --max-time 15 "https://${domain}/?go-get=1" || true
else
  echo "curl: not found"
fi
echo

echo "== go-import discovery from go.mod =="
if [[ -n "$module_dir" && -f "$module_dir/go.mod" ]]; then
  if command -v curl >/dev/null 2>&1; then
    grep -Eo "${domain}/[^[:space:]]+" "$module_dir/go.mod" \
      | sed 's/[[:space:]]*$//' \
      | sort -u \
      | head -20 \
      | while read -r module_path; do
          echo "-- https://${module_path}?go-get=1"
          curl -fsSL --max-time 15 "https://${module_path}?go-get=1" | grep -Eo '<meta name="go-import"[^>]+>|go get [^<]+' || true
        done
  else
    echo "curl: not found"
  fi
else
  echo "skipped: pass a module directory as the second argument"
fi
echo

echo "== optional go module download =="
if [[ -n "$module_dir" ]]; then
  if [[ -f "$module_dir/go.mod" ]]; then
    go -C "$module_dir" mod download -x
  else
    echo "no go.mod at: $module_dir"
    exit 3
  fi
else
  echo "skipped: pass a module directory as the second argument"
fi
