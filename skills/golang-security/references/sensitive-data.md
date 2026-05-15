# Sensitive Data Protection

## 1. No Hardcoded Secrets 【必须】

Never hardcode passwords, API keys, or other sensitive information in source code. Use a config center or secret management system.

## 2. Safe Logging 【必须】

- Only log the minimum necessary data
- Never log passwords (plaintext or ciphertext), keys, or tokens
- For sensitive data that must be displayed, mask/redact it

```go
// BAD: logging password
log.Printf("Registering new user %s with password %s.\n", user, pw)

// GOOD: log username only
log.Printf("Registering new user %s.\n", user)
```

Also avoid leaking sensitive data through:
- GET parameters (visible in URLs, logs, browser history)
- Code comments
- Form auto-fill
- Caching headers

## 3. Encrypted Storage 【必须】

- Encrypt sensitive data at rest using SHA2, RSA, or AES
- Use separate storage for sensitive data with access controls
- Delete temporary files containing sensitive data immediately after use

## 4. Error Handling & Logging 【必须】

Use `panic`/`recover`/`defer` to handle exceptions properly. Never expose internal error details to end users.

```go
defer func() {
    if r := recover(); r != nil {
        log.Printf("Recovered: %v", r)
        http.Error(w, "Internal Server Error", http.StatusInternalServerError)
    }
}()
```

Never enable debug mode or expose runtime logs in production:

```go
// BAD: exposing debug endpoint publicly
dlv --listen=:2345 --headless=true --api-version=2 debug test.go

// GOOD: local debugging only
dlv debug test.go
```
