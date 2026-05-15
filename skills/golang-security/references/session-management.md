# Session & Access Control

## 1. Secure Session Management 【必须】

- Regenerate session on login
- Destroy session on logout
- Use secure cookie attributes: `HttpOnly`, `Secure`, proper `Domain`, and `Expires`

```go
// Creating a secure session cookie
func setToken(res http.ResponseWriter, req *http.Request) {
    expireCookie := time.Now().Add(30 * time.Minute)
    cookie := http.Cookie{
        Name:     "Auth",
        Value:    signedToken,
        Expires:  expireCookie,
        HttpOnly: true,   // inaccessible to JavaScript
        Path:     "/",
        Domain:   "example.com",
        Secure:   true,   // HTTPS only
    }
    http.SetCookie(res, &cookie)
}

// Destroying session on logout
func logout(res http.ResponseWriter, req *http.Request) {
    deleteCookie := http.Cookie{
        Name:    "Auth",
        Value:   "none",
        Expires: time.Now(), // immediately expire
    }
    http.SetCookie(res, &deleteCookie)
}
```

## 2. CSRF Protection 【必须】

Any sensitive operation or data-reading endpoint must verify `Referer` or use CSRF tokens.

```go
import "github.com/gorilla/csrf"

func main() {
    r := mux.NewRouter()
    r.HandleFunc("/signup", ShowSignupForm)
    r.HandleFunc("/signup/post", SubmitSignupForm)
    http.ListenAndServe(":8000",
        csrf.Protect([]byte("32-byte-long-auth-key"))(r))
}
```

## 3. Default Authentication 【必须】

- Default to requiring authentication for all endpoints
- Use a whitelist to exempt public endpoints
- Apply least-privilege: different roles for read/write/admin
- User-specific data access must verify `session.userid`:

```sql
-- Always scope queries to the authenticated user
SELECT id FROM orders WHERE id = :id AND user_id = :session_user_id
```

- Login with password requires secondary verification (CAPTCHA, 2FA)
