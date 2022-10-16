## An array with `seq` overflow.
## 
## Example use:
##     var list: DynArray[5, int]
##     # The first 5 items will use the array.
##     for i in 0..<5:
##       list.add i
##     # When the count exceeds the array length a seq is used.
##     for i in 0..<5:
##       list.add i
## 

type
  DynArray*[N: static[int], T] = object
    length: int
    entries*: array[N, T]
    extras*: seq[T]

func len*[N, T](b: DynArray[N, T]): int = b.length + b.extras.len

proc clear*[N, T](b: var DynArray[N, T]) =
  ## Assumes you have handled stored entities.
  b.length = 0
  b.extras.setLen 0

proc add*[N, T](b: var DynArray[N, T], value: T) =
  if b.length < b.entries.len:
    assert b.length >= 0
    b.entries[b.length] = value
    b.length += 1
  else:
    b.extras.add value

proc del*[N, T](b: var DynArray[N, T], index: int): T =
  ## Indexes beyond the static `N` are taken to be indexing into `extras`.
  assert index >= 0 and index < b.len, "Index out of range: " & $index & " (len = " & $b.len & ")"
  if index < b.length:
    # The user should handle deleted items.
    result = b.entries[index]

    if index < b.length - 1:
      # Swap with the end entry.
      # Note that this makes external indexes volatile.
      b.entries[index] = b.entries[b.length - 1]
    
    b.length -= 1
  else:
    let offsetIdx = index - b.length
    result = b.extras[offsetIdx]
    
    b.extras.del offsetIdx

proc `[]`*[N, T](b: DynArray[N, T], index: int): T =
  ## Indexing is continuous from the last entry to extras.
  if index < b.length:
    b.entries[index]
  else:
    b.extras[index - b.length]

proc `[]=`*[N, T](b: var DynArray[N, T], index: int, value: T) =
  ## Indexing is continuous from the last entry to extras.
  if index < b.length:
    b.entries[index] = value
  else:
    b.extras[index - b.length] = value

proc `[]`*[N, T](b: DynArray[N, T], bIndex: BackwardsIndex): T =
  b[b.len - bIndex.int]

proc `[]=`*[N, T](b: DynArray[N, T], bIndex: BackwardsIndex, value: T) =
  b[b.len - bIndex.int] = value

proc find*[N, T](b: DynArray[N, T], value: T): int =
  ## Find an entity and returns its index.
  result = -1
  for i in 0 ..< b.length:
    if value == b.entries[i]:
      return i
  # Look in extras.
  for i in 0 ..< b.extras.len:
    if value == b.extras[i]:
      return b.length + i

proc contains*[N, T](b: DynArray[N, T], value: T): bool =
  if b.find(value) > -1: true
  else: false

iterator items*[N, T](b: DynArray[N, T]): T =
  var i: int
  while i < b.length:
    yield b.entries[i]
    i.inc
  i = 0
  while i < b.extras.len:
    yield b.extras[i]
    i.inc

iterator pairs*[N, T](b: DynArray[N, T]): (int, T) =
  var i: int
  for e in b:
    yield (i, e)
    i.inc

func toSeq*[N, T](b: DynArray[N, T]): seq[T] =
  result.setLen b.len
  var i: int
  for value in b:
    result[i] = value
    i.inc

proc toDynArray*[T](s: openArray[T], N: static[int]): DynArray[N, T] =
  for entry in s:
    result.add entry


proc `$`*[N, T](b: DynArray[N, T]): string =
  result = "DynArray[" & $N & ", " & $T & "] (" & $(b.len) & " items)"

  if b.len > 0:
    result &= ": "
  for i, value in b:
    if i > 0: result &= ", "
    result &= $value
    if i >= b.length:
      result &= " (D)"
  result &= " ]"

