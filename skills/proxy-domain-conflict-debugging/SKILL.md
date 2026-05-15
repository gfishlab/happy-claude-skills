---
name: proxy-domain-conflict-debugging
description: Diagnose and fix conflicts between VPN/proxy settings and internal company domains, especially when terminal HTTP/HTTPS/ALL_PROXY, NO_PROXY/no_proxy, macOS GUI launch environment, Git proxy config, Go module settings, or Clash/Mihomo VPN fake-ip DNS cause private Git or Go module downloads to fail. Use when errors mention EOF, unrecognized import path, ?go-get=1, Could not resolve host, terminal prompts disabled, authentication required, private GOPRIVATE/GONOPROXY/GONOSUMDB domains, 502 Bad Gateway from proxy, ERR_CONNECTION_CLOSED in browser, or company domains that must bypass local VPN/proxy tools such as Clash, Surge, or corporate VPN. Also triggers when internal Kubernetes domains (*.vault, *.svc, *.cluster.local) or company domains fail while a VPN/proxy tool is active.
---

# Proxy Domain Conflict Debugging

Use this skill to turn proxy/private-domain failures into a repeatable diagnosis. Keep the model of the problem simple:

- Public internet dependencies usually use `HTTP_PROXY`/`HTTPS_PROXY`/`ALL_PROXY` or `GOPROXY`.
- Internal company domains must often bypass local proxy tools through `NO_PROXY/no_proxy`, Git URL-specific proxy overrides, and Go private-module settings.
- IDEs launched from macOS GUI may not inherit terminal environment variables.
- Fake-IP DNS ranges such as `198.18.0.0/15` often mean the proxy tool is still involved even when `NO_PROXY` looks correct.

## Quick Workflow

1. Identify the failing domain from logs. For Go failures, look for the host in `https://host/path?go-get=1`.
2. Run `scripts/diagnose_proxy_domain.sh <domain> [go-module-dir]` from this skill.
3. Compare terminal env, Go env, Git proxy config, GUI `launchctl` env, DNS result, `curl`, and `git ls-remote`.
4. Apply the smallest correction needed:
   - Add company domains to `NO_PROXY` and `no_proxy`.
   - Add company domains to `GOPRIVATE`, `GONOPROXY`, and `GONOSUMDB`.
   - Add or fix Git host-specific empty proxy override.
   - Set GUI env with `launchctl setenv` and restart the IDE.
   - Adjust the proxy/VPN tool routing rule when DNS resolves to fake-IP and direct access still fails.

## Commands To Prefer

Inspect current proxy environment:

```bash
env | rg -i '^(http_proxy|https_proxy|all_proxy|no_proxy|HTTP_PROXY|HTTPS_PROXY|ALL_PROXY|NO_PROXY)='
```

Inspect Go private module routing:

```bash
go env GOPRIVATE GOPROXY GONOPROXY GONOSUMDB GOENV
```

Inspect Git proxy overrides:

```bash
git config --global --get-regexp 'http\..*proxy|https\..*proxy|url\..*insteadOf|credential'
git config --local --get-regexp 'http\..*proxy|https\..*proxy|url\..*insteadOf|credential'
```

Inspect macOS GUI environment for IDEs:

```bash
launchctl getenv NO_PROXY
launchctl getenv no_proxy
launchctl getenv HTTPS_PROXY
```

## Fix Patterns

For a new internal domain `code.example.internal`, add it consistently:

```bash
go env -w GOPRIVATE='existing.example,code.example.internal'
go env -w GONOPROXY='existing.example,code.example.internal'
go env -w GONOSUMDB='existing.example,code.example.internal'

export NO_PROXY="$NO_PROXY,code.example.internal,.example.internal"
export no_proxy="$no_proxy,code.example.internal,.example.internal"
```

For Git, prefer a host-specific empty proxy override instead of removing the global proxy:

```bash
git config --global http.https://code.example.internal.proxy ""
git config --global http.https://code.example.internal/.proxy ""
```

For macOS GUI-launched IDEs, set the same bypass list in the launch environment and restart the IDE:

```bash
launchctl setenv NO_PROXY "$NO_PROXY"
launchctl setenv no_proxy "$no_proxy"
```

## Go Module Download Procedure

Always run Go commands in the directory containing the relevant `go.mod`, or use `go -C`:

```bash
cd path/to/module
go mod download -x
```

Interpret common failures:

- `?go-get=1: EOF`: network/proxy/VPN path is being cut before Go can read module discovery metadata.
- `unrecognized import path`: Go could not fetch or parse the `go-import` meta tag.
- `terminal prompts disabled`: Git needs credentials but Go disabled interactive prompts.
- `Could not resolve host`: DNS/routing problem or disconnected VPN.
- `authentication required`: network path works; credentials or repository permissions are wrong.

Confirm module discovery manually:

```bash
curl -v 'https://domain/path?go-get=1'
```

If this succeeds, confirm Git access:

```bash
git ls-remote https://domain/group/repo.git HEAD
```

## Clash / Mihomo VPN Configuration

When the proxy tool is Clash or Mihomo (including Clash Verge Rev, ClashX), internal domains may fail even with correct `NO_PROXY` and routing rules because the VPN tool intercepts DNS and uses fake-ip or public DNS that cannot resolve internal domains.

### Problem Model

Three layers must all be correct for internal domains to work with Clash active:

| Layer | What can go wrong |
|-------|-------------------|
| **Terminal env** | `http_proxy` forces traffic through proxy; internal domain missing from `no_proxy` |
| **Clash routing rules** | No rule sends internal domain to DIRECT, or rule uses wrong outbound name |
| **Clash DNS** | fake-ip mode assigns fake IPs; public DNS (223.5.5.5, 1.1.1.1) cannot resolve internal domains |

Symptoms by failing layer:

- **Terminal `no_proxy` missing**: `curl -v` shows `Connected to 127.0.0.1 port 7897` (proxy port) and returns 502.
- **Clash rules missing**: traffic enters Clash but routes through proxy node instead of DIRECT.
- **Clash DNS (fake-ip)**: rule says DIRECT but connection still fails; `dig` via system DNS resolves correctly but Clash DNS returns a `198.18.x.x` fake IP or NXDOMAIN. Browser shows `ERR_CONNECTION_CLOSED`.

### Quick Diagnosis

```bash
# 1. Check if terminal proxy is bypassing the domain
curl -v internal.domain:port 2>&1 | head -5
# If you see "Connected to 127.0.0.1 port 7897" → add domain to no_proxy

# 2. Check if Clash can resolve the domain (compare with system DNS)
dig +short internal.domain
# vs what Clash DNS returns (if dns.listen is active):
dig +short @127.0.0.1 -p 53 internal.domain
# If Clash DNS returns 198.18.x.x or fails → need nameserver-policy or fake-ip-filter

# 3. Check Clash running config for rules and DNS
# Clash Verge Rev:
grep -A5 '^rules:' ~/Library/Application\ Support/io.github.clash-verge-rev.clash-verge-rev/clash-verge.yaml | head -10
grep -A20 '^dns:' ~/Library/Application\ Support/io.github.clash-verge-rev.clash-verge-rev/clash-verge.yaml
```

### Fix: Clash Verge Rev Global Merge

Edit the global Merge profile to fix DNS and routing for internal domains. This persists across subscription switches and re-imports.

File location: `~/Library/Application Support/io.github.clash-verge-rev.clash-verge-rev/profiles/Merge.yaml`

```yaml
# Profile Enhancement Merge Template for Clash Verge

profile:
  store-selected: true

dns:
  nameserver-policy:
    "*.yourcompany.com": system
    "*.vault": system
    "*.svc": system
    "*.cluster.local": system
  fake-ip-filter:
    - "*.yourcompany.com"
    - "*.vault"
    - "*.svc"
    - "*.cluster.local"

prepend-rules:
  - DOMAIN-SUFFIX,yourcompany.com,DIRECT
  - DOMAIN-SUFFIX,vault,DIRECT
  - DOMAIN-SUFFIX,svc,DIRECT
  - DOMAIN-SUFFIX,cluster.local,DIRECT
```

Key fields explained:

- **`nameserver-policy`**: Routes DNS queries for matching domains to `system` DNS (the OS resolver, typically company VPN DNS) instead of Clash's public nameservers. Without this, Clash cannot resolve internal domains even with DIRECT rules.
- **`fake-ip-filter`**: Prevents Clash from assigning fake IPs (`198.18.x.x`) to these domains. Required because fake-ip is the default `enhanced-mode` in Mihomo, and DIRECT outbound with a fake IP will not work for internal services.
- **`prepend-rules`**: Inserts routing rules before subscription rules to ensure internal domains go to `DIRECT` outbound. Using `DIRECT` (built-in) instead of a named proxy group like `🎯 全球直连` ensures it works regardless of subscription.

**Important**: After editing Merge.yaml, the user must reload the profile in Clash Verge Rev (click re-activate or restart the app).

### Fix: Terminal no_proxy

Also add internal domains to the terminal `no_proxy` so CLI tools (curl, Go apps) bypass the proxy:

```bash
# In ~/.zshrc or ~/.bashrc
export no_proxy="$no_proxy,.yourcompany.com,.vault,.svc,.cluster.local"
export NO_PROXY="$no_proxy"
```

### Fix: /etc/hosts Check

If the internal domain resolves to `127.0.0.1` (via `/etc/hosts`), the service needs a port-forward to be accessible locally:

```bash
grep internal.domain /etc/hosts
# If it maps to 127.0.0.1, ensure port-forward is running:
# kubectl port-forward svc/vault -n vault 8200:8200
```

### Verification Checklist

After applying fixes, verify each layer:

```bash
# 1. Terminal bypasses proxy for the domain
curl -v internal.domain:port 2>&1 | grep -E 'Connected to|Trying'
# Should show direct connection, NOT proxy port

# 2. Clash DNS resolves correctly
dig +short @127.0.0.1 -p 53 internal.domain
# Should return real IP, NOT 198.18.x.x

# 3. Clash rules include DIRECT for the domain
grep 'internal.domain' ~/Library/Application\ Support/io.github.clash-verge-rev.clash-verge-rev/clash-verge.yaml
# Should show DIRECT rule

# 4. Browser can access (if applicable)
# Open https://internal.domain in browser — should load without ERR_CONNECTION_CLOSED
```

## Safety

Do not delete user proxy settings as a first response. Prefer additive, domain-specific bypasses and host-specific Git overrides. Ask before changing persistent global config unless the user explicitly asked to fix the machine.

## Resources

- `scripts/diagnose_proxy_domain.sh`: read-only diagnostic script for proxy, Git, Go, DNS, curl, Clash/Mihomo config, and optional Go module checks.
- `references/go-private-modules.md`: compact reference for Go private module routing and failure interpretation.
