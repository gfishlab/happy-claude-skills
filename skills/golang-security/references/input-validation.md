# Input Validation

## 1. Type-Based Validation 【必须】

All external input must be validated using a whitelist approach. Use `github.com/go-playground/validator/v10` for struct/field validation.

```go
import "github.com/go-playground/validator/v10"

var validate = validator.New()

type RegisterRequest struct {
    Email    string `validate:"required,email"`
    Username string `validate:"required,min=3,max=50"`
    Age      int    `validate:"gte=1,lte=120"`
}

func handleRegister(req RegisterRequest) error {
    return validate.Struct(req)
}
```

For standalone variable validation:

```go
func validateVariable() {
    myEmail := "abc@example.com"
    errs := validate.Var(myEmail, "required,email")
    if errs != nil {
        fmt.Println(errs)
        return
    }
    // proceed
}
```

Validation should cover:
- Data length (min/max)
- Data range
- Data type and format
- Character set (reject unexpected characters)

## 2. HTML Encoding 【必须】

For input that cannot be whitelisted, encode dangerous characters using `html.EscapeString`, `text/template`, or `bluemonday`:

```go
import "html/template"

escapedResult := template.HTMLEscapeString(inputValue)
```

Or use `html/template` for automatic escaping:

```go
import "html/template"

func handler(w http.ResponseWriter, r *http.Request) {
    param := r.URL.Query().Get("param")
    tmpl := template.New("hello")
    tmpl, _ = tmpl.Parse(`{{define "T"}}{{.}}{{end}}`)
    tmpl.ExecuteTemplate(w, "T", param) // auto-escapes HTML
}
```

## 3. ReDoS Prevention 【推荐】

Use Go's `regexp` package which guarantees linear-time matching and has memory limits on parser/compiler/engine. It does not support backreferences or lookaround, which eliminates ReDoS vectors.

```go
matched, err := regexp.MatchString(`a.b`, "aaxbb")
```
