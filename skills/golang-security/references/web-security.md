# Web Security

## 1. Template Injection Prevention 【必须】

Never inject external input directly into Go templates. Only allow whitelisted characters in template variables.

```go
// BAD: user input embedded directly in template string
func handler(w http.ResponseWriter, r *http.Request) {
    r.ParseForm()
    x := r.Form.Get("name")
    var tmpl = `...<p>` + x + `</p>...` // template injection
    t := template.New("main")
    t, _ = t.Parse(tmpl)
    t.Execute(w, "Hello")
}

// GOOD: validate input, then pass as template data
func handler(w http.ResponseWriter, r *http.Request) {
    r.ParseForm()
    x := r.Form.Get("name")
    errs := validate.Var(x, "gte=1,lte=100")
    if errs != nil {
        http.Error(w, "Invalid input", http.StatusBadRequest)
        return
    }
    tmpl := template.New("page")
    tmpl, _ = tmpl.Parse(`<p>{{.}}</p>`) // auto-escaped
    tmpl.Execute(w, x)
}
```

## 2. CORS Configuration 【必须】

Set `Access-Control-Allow-Origin` to specific allowed origins. Never use `*` for authenticated endpoints.

```go
import "github.com/rs/cors"

c := cors.New(cors.Options{
    AllowedOrigins:   []string{"https://example.com", "https://app.example.com"},
    AllowCredentials: true,
    Debug:            false,
})
handler = c.Handler(handler)
```

## 3. Security Response Headers 【必须】

All endpoints must include:

| Header | Value | Purpose |
|--------|-------|---------|
| `X-Content-Type-Options` | `nosniff` | Prevent MIME type sniffing |
| `X-Frame-Options` | `DENY` or `SAMEORIGIN` | Prevent clickjacking |

```go
func securityHeaders(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("X-Content-Type-Options", "nosniff")
        w.Header().Set("X-Frame-Options", "DENY")
        next.ServeHTTP(w, r)
    })
}
```

## 4. Correct Content-Type 【必须】

Response `Content-Type` header must match the actual response body:

```go
// JSON response
w.Header().Set("Content-Type", "application/json")
// XML response
w.Header().Set("Content-Type", "text/xml")
```

## 5. HTTP Response Header Injection 【必须】

Avoid putting user input into response headers. If required, strip `\r` and `\n`:

```go
func sanitizeHeaderValue(val string) string {
    val = strings.ReplaceAll(val, "\r", "")
    val = strings.ReplaceAll(val, "\n", "")
    return val
}
```

## 6. Response Body Encoding 【必须】

When rendering HTML, use `html/template` for automatic escaping, or `html.EscapeString` manually:

```go
import "html/template"

func outtemplate(w http.ResponseWriter, r *http.Request) {
    param1 := r.URL.Query().Get("param1")
    tmpl := template.New("hello")
    tmpl, _ = tmpl.Parse(`{{define "T"}}{{.}}{{end}}`)
    tmpl.ExecuteTemplate(w, "T", param1)
}
```
