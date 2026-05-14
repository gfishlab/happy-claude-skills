# Go Private Modules And Proxy Conflicts

Use this reference when diagnosing Go dependency failures for company-hosted modules.

## Configuration Roles

- `GOPROXY`: where public modules are downloaded from. Example: `https://goproxy.cn,direct`.
- `GOPRIVATE`: glob list of module prefixes considered private. These bypass checksum DB and usually proxy behavior.
- `GONOPROXY`: module prefixes that must not use `GOPROXY`.
- `GONOSUMDB`: module prefixes that must not use the public checksum database.
- `NO_PROXY/no_proxy`: host bypass list for HTTP clients. Include both exact hosts and parent domain suffixes when useful.

## Go Discovery

For `code.example.internal/team/pkgs/field`, Go may first fetch:

```text
https://code.example.internal/team/pkgs/field?go-get=1
```

The response should include a `go-import` meta tag that maps the module prefix to a VCS repo, for example:

```html
<meta name="go-import" content="code.example.internal/team/pkgs git https://code.example.internal/team/pkgs.git">
```

If the discovery request fails with EOF, focus on VPN/proxy/DNS before changing code.

## Fake-IP Signal

Addresses in `198.18.0.0/15` are benchmark/fake-IP ranges commonly used by proxy tools. If an internal company host resolves there, the proxy tool is still participating in DNS/routing. That can be fine if the proxy has a direct rule for the domain, but it explains why `NO_PROXY` alone may not fully solve the problem.

## Minimum Validation

Run these in order:

```bash
curl -v 'https://domain/path?go-get=1'
git ls-remote https://domain/group/repo.git HEAD
go -C path/to/module mod download -x
```

If `curl` fails, solve network/proxy/VPN/DNS. If `curl` succeeds but Git fails, solve Git credentials or Git proxy. If both succeed but Go fails, inspect `GOPRIVATE`, `GONOPROXY`, and `GONOSUMDB`.
