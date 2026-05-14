---
name: proxy-domain-conflict-debugging
description: Diagnose and fix conflicts between VPN/proxy settings and internal company domains, especially when terminal HTTP/HTTPS/ALL_PROXY, NO_PROXY/no_proxy, macOS GUI launch environment, Git proxy config, and Go module settings cause private Git or Go module downloads to fail. Use when errors mention EOF, unrecognized import path, ?go-get=1, Could not resolve host, terminal prompts disabled, authentication required, private GOPRIVATE/GONOPROXY/GONOSUMDB domains, or company domains that must bypass local VPN/proxy tools such as Clash, Surge, or corporate VPN.
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

## Safety

Do not delete user proxy settings as a first response. Prefer additive, domain-specific bypasses and host-specific Git overrides. Ask before changing persistent global config unless the user explicitly asked to fix the machine.

## Resources

- `scripts/diagnose_proxy_domain.sh`: read-only diagnostic script for proxy, Git, Go, DNS, curl, and optional Go module checks.
- `references/go-private-modules.md`: compact reference for Go private module routing and failure interpretation.
