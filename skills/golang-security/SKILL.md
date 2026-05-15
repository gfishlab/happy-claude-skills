---
name: golang-security
description: "Company Go security coding standards — covers memory safety (slice bounds, nil pointers, integer overflow, make length validation, SetFinalizer pitfalls, channel double-close, goroutine lifecycle, unsafe avoidance), filesystem security (path traversal, file permissions), command injection prevention, TLS/communication security, sensitive data protection (no hardcoded secrets, safe logging, encrypted storage), cryptography (key management, strong algorithms), ReDoS prevention, input validation (validator, HTML encoding), SQL injection prevention (prepared statements, parameterized queries), SSRF prevention, template injection, CORS, security headers, session management, CSRF, access control, and concurrency safety (closure loop variables, concurrent map writes, sync primitives). MUST be used alongside golang-company-standards whenever writing, reviewing, or modifying Go code in any company project — security rules apply to ALL Go code, not just explicitly security-related code. Triggers on: writing Go code, creating .go files, editing Go files, reviewing Go PRs, writing Go tests, Go code review, or any task involving Go source code. Also triggers on: Go security review, security audit, golang security, Go安全, 安全规范, vulnerability prevention, OWASP, injection prevention, 密码管理, 敏感数据, crypto, SQL, HTTP handler, file operations, command execution, goroutine, channel, mutex."
---

# Company Go Security Coding Standards

This skill encodes the company-mandated Go security guidelines. When writing or reviewing Go code, apply these rules. Rules marked 【必须】(MUST) are mandatory; 【推荐】(RECOMMENDED) are strongly encouraged.

## How to Use This Skill

Three modes of operation:

1. **Writing code** — Apply the relevant rules proactively. Check each section that relates to the code being written.
2. **Reviewing code** — Use the checklist in `references/checklist.md` for a structured review covering all domains.
3. **Auditing** — Read the full references for deep inspection of specific vulnerability classes.

## Quick Reference by Domain

| Domain | Key Rules | Detail |
|--------|-----------|--------|
| Memory | Slice bounds, nil checks, integer overflow, make validation, no SetFinalizer+cycles, no double-close channels, goroutine exit | See `references/memory-safety.md` |
| Filesystem | Path traversal prevention, file permissions | See `references/filesystem.md` |
| System | Command injection prevention | See `references/injection.md` |
| Network | TLS required, certificate verification, SSRF prevention | See `references/network.md` |
| Sensitive Data | No hardcoded secrets, safe logging, encrypted storage, error handling | See `references/sensitive-data.md` |
| Cryptography | No hardcoded keys, secure key storage, strong algorithms only | See `references/cryptography.md` |
| Input | Validator-based white-list, HTML encoding | See `references/input-validation.md` |
| SQL | Prepared statements, parameterized queries, no string concatenation | See `references/sql-safety.md` |
| Web | Template injection, CORS, security headers, response encoding | See `references/web-security.md` |
| Session | Secure cookies, CSRF tokens, default auth | See `references/session-management.md` |
| Concurrency | No closure loop vars, no concurrent map writes, sync primitives | See `references/concurrency-safety.md` |

## Critical Rules Summary

These are the most frequently violated rules. Always check for these first:

1. **Never hardcode secrets** — passwords, API keys, encryption keys must come from config/vault
2. **Always validate external input** — use `validator` for struct fields, check slice lengths before indexing, verify nil pointers after Unmarshal
3. **Always use parameterized SQL** — never `fmt.Sprintf` a query string with user input
4. **Always sanitize file paths** — reject `..` in user-provided filenames
5. **Always use TLS** — no plaintext HTTP in production; enable certificate verification
6. **Never log sensitive data** — no passwords, keys, or tokens in logs
7. **Never execute unsanitized shell commands** — whitelist commands, filter metacharacters
8. **Always protect concurrent access** — no concurrent map writes, pass loop variables as args to goroutines
