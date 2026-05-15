# Cryptography

## 1. No Hardcoded Keys/Passwords 【必须】

Never embed encryption keys or passwords in source code.

```go
// BAD: hardcoded database credentials
const (
    user     = "dbuser"
    password = "s3cretp4ssword"
)

// BAD: hardcoded encryption key
var commonkey = []byte("0123456789abcdef")
```

Use environment variables, secret managers, or config centers instead:

```go
// GOOD: load from environment
func connect() (*sql.DB, error) {
    connStr := fmt.Sprintf("postgres://%s:%s@localhost/pqgotest",
        os.Getenv("DB_USER"), os.Getenv("DB_PASSWORD"))
    return sql.Open("postgres", connStr)
}
```

## 2. Secure Key Storage 【必须】

- For sensitive/business data encryption, use asymmetric key exchange to negotiate symmetric keys
- For less sensitive data, use key derivation or transformation algorithms
- Never store keys alongside the data they encrypt

## 3. Use Strong Algorithms 【推荐】

Avoid weak cryptographic algorithms:

| Avoid | Use Instead |
|-------|-------------|
| `crypto/des` | `crypto/aes` |
| `crypto/md5` | `crypto/sha256` or `crypto/sha512` |
| `crypto/sha1` | `crypto/sha256` or `crypto/sha512` |
| `crypto/rc4` | `crypto/aes` |

Strong choices:
- Symmetric: `crypto/aes` (AES-256-GCM preferred)
- Asymmetric: `crypto/rsa` (2048+ bits), `crypto/ecdsa`
- Hashing: `crypto/sha256`, `crypto/sha512`
- Key derivation: `golang.org/x/crypto/bcrypt`, `golang.org/x/crypto/argon2`
