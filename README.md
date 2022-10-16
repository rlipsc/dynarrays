# DynArrays

An array that uses a `seq` for extra items.

Useful for lists that allocate on the stack before using heap memory.

```nim
var da: DynArray[5, int]

# The first 5 items will use the array.
for i in 0 ..< 5:
  da.add i

# When the count exceeds the array length a seq is used.
for i in 5 ..< 10:
  da.add i
```
