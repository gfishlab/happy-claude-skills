# Concurrency Safety

## 1. No Closure Loop Variables 【必须】

When launching goroutines in a loop, capture the loop variable by passing it as a function argument. Otherwise all goroutines share the same variable reference.

```go
// BAD: all goroutines print the same value
for i := 0; i < 5; i++ {
    group.Add(1)
    go func() {
        defer group.Done()
        fmt.Printf("%-2d", i) // i is shared, prints 5,5,5,5,5 or similar
    }()
}

// GOOD: pass loop variable as argument
for i := 0; i < 5; i++ {
    group.Add(1)
    go func(j int) {
        defer func() {
            if r := recover(); r != nil {
                fmt.Println("Recovered in start()")
            }
            group.Done()
        }()
        fmt.Printf("%-2d", j) // j is unique per goroutine
    }(i)
}
```

## 2. No Concurrent Map Writes 【必须】

Concurrent writes to a plain `map` cause `fatal error: concurrent map writes`. Use `sync.Mutex`, `sync.RWMutex`, or `sync.Map`.

```go
// BAD: concurrent map access → crash
m := make(map[int]int)
go func() { for { _ = m[1] } }()
go func() { for { m[2] = 1 } }()

// GOOD: protect with mutex
type SafeMap struct {
    mu sync.RWMutex
    m  map[int]int
}

func (s *SafeMap) Get(key int) int {
    s.mu.RLock()
    defer s.mu.RUnlock()
    return s.m[key]
}

func (s *SafeMap) Set(key, val int) {
    s.mu.Lock()
    defer s.mu.Unlock()
    s.m[key] = val
}
```

## 3. Concurrent Safety for Sensitive Operations 【必须】

Use synchronization primitives (mutexes or atomics) for any shared state in sensitive operations.

**Mutex approach:**

```go
var count int

func Count(lock *sync.Mutex) {
    lock.Lock()
    count++
    fmt.Println(count)
    lock.Unlock()
}

func main() {
    lock := &sync.Mutex{}
    for i := 0; i < 10; i++ {
        go Count(lock)
    }
}
```

Always ensure every `Lock()` has a matching `Unlock()` (use `defer`). Every `RLock()` needs `RUnlock()`.

**Atomic approach:**

```go
import (
    "sync"
    "sync/atomic"
)

func main() {
    type Map map[string]string
    var m atomic.Value
    m.Store(make(Map))
    var mu sync.Mutex

    read := func(key string) string {
        m1 := m.Load().(Map)
        return m1[key]
    }

    insert := func(key, val string) {
        mu.Lock()
        defer mu.Unlock()
        m1 := m.Load().(Map)
        m2 := make(Map)
        for k, v := range m1 {
            m2[k] = v
        }
        m2[key] = val
        m.Store(m2)
    }
}
```
