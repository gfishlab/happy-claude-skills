# Network & Communication Security

## 1. Use TLS for All Network Communication 【必须】

All production communication must use TLS (at least TLS 1.2, preferably 1.3). This applies to HTTP, gRPC, WebSockets, and any other protocol.

```go
// GOOD: HTTPS with HSTS
func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
        w.Header().Add("Strict-Transport-Security", "max-age=63072000; includeSubDomains")
        w.Write([]byte("This is an example server.\n"))
    })
    log.Fatal(http.ListenAndServeTLS(":443", "yourCert.pem", "yourKey.pem", nil))
}
```

## 2. Enable TLS Certificate Verification 【推荐】

Production environments must enable certificate verification. Never set `InsecureSkipVerify: true` in production.

```go
// BAD: skips certificate verification
tr := &http.Transport{
    TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
}

// GOOD: verify certificates
tr := &http.Transport{
    TLSClientConfig: &tls.Config{InsecureSkipVerify: false},
}
```

## 3. SSRF Prevention 【必须】

When making HTTP requests with externally-controlled URLs (`http.Get`, `http.Post`, `http.Do`, etc.), follow this 6-step validation flow:

1. Only allow `http://` or `https://` schemes
2. Parse the URL and extract its HOST
3. Resolve HOST to IP, convert to long format, check against private ranges:
   - `10.0.0.0/8`
   - `172.16.0.0/12`
   - `192.168.0.0/16`
   - `127.0.0.0/8`
   - Also add any custom private ranges
4. Make the request
5. If the response redirects, go back to step 1 and re-validate the redirect URL
6. If no redirect, bind the validated IP+domain and make the request

```go
func safeHTTPGet(rawURL string) (*http.Response, error) {
    privateRanges := []struct{ ip, mask string }{
        {"10.0.0.0", "255.0.0.0"},
        {"172.16.0.0", "255.240.0.0"},
        {"192.168.0.0", "255.255.0.0"},
        {"127.0.0.0", "255.0.0.0"},
    }

    u, err := url.Parse(rawURL)
    if err != nil {
        return nil, err
    }
    if u.Scheme != "http" && u.Scheme != "https" {
        return nil, errors.New("only http/https allowed")
    }

    ips, err := net.LookupIP(u.Hostname())
    if err != nil {
        return nil, err
    }
    for _, ip := range ips {
        for _, r := range privateRanges {
            _, cidr, _ := net.ParseCIDR(r.ip + "/8")
            if cidr.Contains(ip) {
                return nil, errors.New("private IP not allowed")
            }
        }
    }

    // Disable redirect auto-follow to re-validate on each hop
    client := &http.Client{
        CheckRedirect: func(req *http.Request, via []*http.Request) error {
            // Re-validate each redirect (step 5 — loop back to step 1)
            return validateURL(req.URL.String())
        },
    }
    return client.Get(rawURL)
}
```

For domains within a known set, use a whitelist instead:

```go
var allowedHosts = map[string]bool{
    "a.example.com": true,
    "b.example.com": true,
}

func isAllowedHost(rawURL string) bool {
    u, err := url.Parse(rawURL)
    if err != nil {
        return false
    }
    if u.Scheme != "http" && u.Scheme != "https" {
        return false
    }
    return allowedHosts[u.Hostname()]
}
```

## 4. XXE Prevention

Go's `encoding/xml` does not support external entity references by default, so using the standard library is safe against XXE. No special configuration needed.
