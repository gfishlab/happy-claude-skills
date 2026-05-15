# SQL Safety

## 1. Prepared Statements with Parameterized Queries 【必须】

Always use prepared statements with bound parameters. Never concatenate user input into SQL strings.

Using `database/sql`:

```go
// GOOD: parameterized query
func handlerGood(db *sql.DB, category string) {
    q := "SELECT ITEM, PRICE FROM PRODUCT WHERE ITEM_CATEGORY = ? ORDER BY PRICE"
    rows, err := db.Query(q, category)
    // ...
}
```

Using GORM:

```go
// GOOD: GORM handles parameterization
db.First(&product, 1)
db.Where("item_category = ?", category).Find(&products)
```

```go
// BAD: string concatenation enables SQL injection
func handler(db *sql.DB, req *http.Request) {
    q := fmt.Sprintf("SELECT ITEM,PRICE FROM PRODUCT WHERE ITEM_CATEGORY='%s' ORDER BY PRICE",
        req.URL.Query()["category"])
    db.Query(q)
}
```

## 2. Validate ORDER BY and Table Names

Parameterized queries cannot be used for column names, table names, or ORDER BY clauses. These must be validated through a whitelist:

```go
var allowedSortColumns = map[string]bool{
    "price":       true,
    "name":        true,
    "created_at":  true,
}

func buildOrderBy(sortParam string) string {
    if allowedSortColumns[sortParam] {
        return sortParam
    }
    return "id" // safe default
}
```
