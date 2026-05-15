# Security Review Checklist

Use this checklist when reviewing or auditing Go code for security compliance.

## Memory Safety
- [ ] All slice indexing preceded by length check
- [ ] All pointer dereferences guarded by nil check (especially after Unmarshal)
- [ ] Integer arithmetic validated for overflow/underflow
- [ ] `make()` calls with external sizes have upper-bound checks
- [ ] No `SetFinalizer` used with pointer cycles
- [ ] Channel closes happen exactly once (use `defer close`)
- [ ] All goroutines have exit conditions (context cancellation or done channel)
- [ ] No use of `unsafe` package (or thoroughly validated if unavoidable)

## Filesystem
- [ ] File paths from external input sanitized (reject `..`)
- [ ] File permissions are restrictive (default `0640`, secrets `0600`)

## Command Execution
- [ ] No shell invocation with unsanitized user input (`sh -c`, `bash -c`)
- [ ] Command names whitelisted if externally controlled
- [ ] Shell metacharacters filtered: `\n $ & ; | ' " ( ) \``

## Network
- [ ] All communication uses TLS
- [ ] TLS certificate verification enabled (`InsecureSkipVerify: false`)
- [ ] HTTP requests with external URLs validated against SSRF (no private IPs)

## Sensitive Data
- [ ] No hardcoded secrets, passwords, or keys in source code
- [ ] Logs do not contain passwords, keys, or tokens
- [ ] Sensitive data encrypted at rest (AES, RSA, SHA2)
- [ ] Error responses do not leak internal details
- [ ] Debug mode disabled in production

## Cryptography
- [ ] Encryption keys not hardcoded
- [ ] Keys stored securely (vault, KMS)
- [ ] No weak algorithms (DES, MD5, SHA1, RC4)

## Input Validation
- [ ] All external input validated with `validator` or equivalent
- [ ] HTML output encoded with `html/template` or `html.EscapeString`
- [ ] Regular expressions use `regexp` package (not third-party ReDoS-vulnerable libs)

## SQL
- [ ] All queries use prepared statements / parameterized queries
- [ ] No string concatenation in SQL with user input
- [ ] ORDER BY / table names validated through whitelist

## Web
- [ ] Template rendering does not embed external input in template strings
- [ ] CORS configured with specific origins (not `*` for authenticated endpoints)
- [ ] `X-Content-Type-Options: nosniff` set on all responses
- [ ] `X-Frame-Options` set on all responses
- [ ] Content-Type matches response body
- [ ] No user input in response headers without stripping `\r`, `\n`
- [ ] Response body HTML-escaped

## Session & Auth
- [ ] Session regenerated on login
- [ ] Session destroyed on logout
- [ ] Cookies use `HttpOnly`, `Secure`, proper `Domain`, `Expires`
- [ ] CSRF tokens on sensitive operations
- [ ] Default deny — all endpoints require auth unless whitelisted
- [ ] User-scoped data queries include `user_id` check

## Concurrency
- [ ] Loop variables passed as goroutine arguments (not captured by closure)
- [ ] No concurrent map writes without mutex
- [ ] Shared state protected by `sync.Mutex`, `sync.RWMutex`, or `sync/atomic`
- [ ] Every `Lock()`/`RLock()` has matching `Unlock()`/`RUnlock()` (use `defer`)
