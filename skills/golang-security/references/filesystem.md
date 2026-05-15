# Filesystem Security

## 1. Path Traversal Prevention 【必须】

External filenames must be sanitized to prevent `../` traversal leading to arbitrary file read/write.

```go
// BAD: arbitrary file read
func handler(w http.ResponseWriter, r *http.Request) {
    path := r.URL.Query()["path"][0]
    data, _ := os.ReadFile(path) // reads any file
    w.Write(data)

    data, _ = os.ReadFile(filepath.Join("/home/user/", path)) // still vulnerable to ../
    w.Write(data)
}

// BAD: arbitrary file write via zip
func unzip(f string) {
    r, _ := zip.OpenReader(f)
    for _, f := range r.File {
        p, _ := filepath.Abs(f.Name) // may contain ../
        os.WriteFile(p, []byte("present"), 0640)
    }
}

// GOOD: reject path traversal
func unzipGood(f string) bool {
    r, err := zip.OpenReader(f)
    if err != nil {
        return false
    }
    for _, f := range r.File {
        if strings.Contains(f.Name, "..") {
            return false
        }
        p, _ := filepath.Abs(f.Name)
        os.WriteFile(p, []byte("present"), 0640)
    }
    return true
}
```

For general path sanitization:
```go
func sanitizePath(base, userPath string) (string, error) {
    absBase, err := filepath.Abs(base)
    if err != nil {
        return "", err
    }
    joined := filepath.Join(absBase, userPath)
    absJoined, err := filepath.Abs(joined)
    if err != nil {
        return "", err
    }
    if !strings.HasPrefix(absJoined, absBase) {
        return "", errors.New("path traversal detected")
    }
    return absJoined, nil
}
```

## 2. File Permissions 【必须】

Set restrictive permissions based on sensitivity. Default to `0640` (owner read/write, group read).

```go
// GOOD: restrictive permissions
os.WriteFile(p, data, 0640) // -rw-r-----
```

Common permission levels:
- Sensitive config/secrets: `0600` (owner only)
- General data files: `0640` (owner + group read)
- Executables: `0750` (owner execute, group read/execute)
