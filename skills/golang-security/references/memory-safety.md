# Memory Safety

## 1. Slice Length Validation 【必须】

Always check slice length before indexing. Unchecked access causes `panic: index out of range`.

```go
// BAD: no length check
func decode(data []byte) bool {
    if data[0] == 'F' && data[1] == 'U' && data[2] == 'Z' && data[3] == 'Z' &&
       data[4] == 'E' && data[5] == 'R' {
        return true
    }
    return false
}

// GOOD: validate length first
func decode(data []byte) bool {
    if len(data) == 6 {
        if data[0] == 'F' && data[1] == 'U' && data[2] == 'Z' && data[3] == 'Z' &&
           data[4] == 'E' && data[5] == 'R' {
            return true
        }
    }
    return false
}
```

Also check slice bounds for slicing operations:
```go
// BAD: slice[:10] on a slice of length 7 → panic
var slice = []int{0, 1, 2, 3, 4, 5, 6}
fmt.Println(slice[:10])

// GOOD: check before slicing
if len(slice) >= 10 {
    fmt.Println(slice[:10])
}
```

## 2. Nil Pointer Checks 【必须】

Always check pointers for nil after Unmarshal or any operation that may not initialize them.

```go
// BAD: packet.Data may be nil
func main() {
    packet := new(Packet)
    data := make([]byte, 2)
    if err := packet.UnmarshalBinary(data); err != nil {
        return
    }
    fmt.Printf("Stat: %v\n", packet.Data.Stat) // panic if Data is nil
}

// GOOD: check nil before dereference
func main() {
    packet := new(Packet)
    data := make([]byte, 2)
    if err := packet.UnmarshalBinary(data); err != nil {
        return
    }
    if packet.Data == nil {
        return
    }
    fmt.Printf("Stat: %v\n", packet.Data.Stat)
}
```

## 3. Integer Safety 【必须】

Prevent overflow in arithmetic with externally-controlled values. Check results after operations.

Scenarios requiring strict bounds checking:
- Array indices
- Object lengths/sizes
- Loop counters from external input

```go
// BAD: no overflow check
func overflow(numControlByUser int32) {
    var numInt int32 = 0
    numInt = numControlByUser + 1 // can overflow
    fmt.Printf("%d\n", numInt)
}

// GOOD: detect overflow
func overflow(numControlByUser int32) {
    var numInt int32 = 0
    numInt = numControlByUser + 1
    if numInt < 0 {
        fmt.Println("integer overflow")
        return
    }
    fmt.Println("integer ok")
}
```

Also ensure:
- Unsigned integers don't wrap around
- Integer type conversions don't truncate
- Signed-to-unsigned conversions don't cause sign errors

## 4. Make Allocation Length Validation 【必须】

When `make()` receives an externally-controlled size, validate it to prevent OOM or panic.

```go
// BAD: no size limit
func parse(lenControlByUser int, data []byte) {
    size := lenControlByUser
    buffer := make([]byte, size) // can panic or exhaust memory
    copy(buffer, data)
}

// GOOD: cap the size
func parse(lenControlByUser int, data []byte) ([]byte, error) {
    size := lenControlByUser
    if size > 64*1024*1024 {
        return nil, errors.New("value too large")
    }
    buffer := make([]byte, size)
    copy(buffer, data)
    return buffer, nil
}
```

## 5. No SetFinalizer with Pointer Cycles 【必须】

`runtime.SetFinalizer()` cannot execute on objects in pointer cycles because the GC cannot determine finalization order, causing memory leaks.

```go
// BAD: circular reference + SetFinalizer = memory leak
func foo() {
    var a, b Data
    a.o = &b
    b.o = &a
    runtime.SetFinalizer(&a, func(d *Data) { fmt.Printf("a %p final.\n", d) })
    runtime.SetFinalizer(&b, func(d *Data) { fmt.Printf("b %p final.\n", d) })
}
```

Never combine `SetFinalizer` with circular pointer references.

## 6. No Double-Close on Channels 【必须】

Closing a channel twice causes `panic`. Use `defer close()` to guarantee single close.

```go
// BAD: double close in error path
func foo(c chan int) {
    defer close(c)
    err := processBusiness()
    if err != nil {
        c <- 0
        close(c) // panic: close of closed channel
        return
    }
    c <- 1
}

// GOOD: defer handles close, error path just returns
func foo(c chan int) {
    defer close(c)
    err := processBusiness()
    if err != nil {
        c <- 0
        return
    }
    c <- 1
}
```

## 7. Goroutine Must Have Exit Conditions 【必须】

Every goroutine needs a termination condition. Unbounded goroutines leak memory.

```go
// BAD: no exit condition
func doWaiter(name string, second int) {
    for {
        time.Sleep(time.Duration(second) * time.Second)
        fmt.Println(name, " is ready!")
    }
}

// GOOD: use context or done channel
func doWaiter(ctx context.Context, name string, second int) {
    ticker := time.NewTicker(time.Duration(second) * time.Second)
    defer ticker.Stop()
    for {
        select {
        case <-ctx.Done():
            return
        case <-ticker.C:
            fmt.Println(name, " is ready!")
        }
    }
}
```

## 8. Avoid unsafe Package 【推荐】

`unsafe` bypasses Go's memory safety. Avoid it. If absolutely necessary, add thorough validation.

```go
// BAD: arbitrary memory access via unsafe
func unsafePointer() {
    b := make([]byte, 1)
    foo := (*int)(unsafe.Pointer(uintptr(unsafe.Pointer(&b[0])) + uintptr(0xfffffffe)))
    fmt.Print(*foo + 1) // SIGSEGV
}
```

## 9. Prefer Arrays Over Slices as Function Params 【推荐】

Slices passed to functions share the underlying array — mutations affect the caller's data.

```go
// BAD: slice mutations affect original
func modify(array []int) {
    array[0] = 10
}
func main() {
    array := []int{1, 2, 3, 4, 5}
    modify(array)
    fmt.Println(array) // [10 2 3 4 5]
}

// GOOD: array is copied on pass
func modify(array [5]int) {
    array[0] = 10 // only modifies the copy
}
func main() {
    array := [5]int{1, 2, 3, 4, 5}
    modify(array)
    fmt.Println(array) // [1 2 3 4 5]
}
```
