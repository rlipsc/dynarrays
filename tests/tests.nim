import dynarrays, unittest

type Entry = (int, int)

suite "DynArray":
  var
    b: DynArray[1, Entry]
    entries: seq[Entry]
    entCount = 10
  
  proc `$`(e: Entry): string = $e[0].int & "/" & $e[1].int

  # Create some entries.
  for i in 0 ..< entCount:
    entries.add (i, i)

  test "One item":
    b.add entries[0]
    check b.len == 1
    check b.toSeq == entries[0..0]

  test "Clear":
    b.clear
    check b.len == 0

  test "Extras overflow":
    for e in entries:
      b.add e
    check b.toSeq == entries

  test "Indexed read":
    for i in 0 ..< entries.len:
      check b[i] == entries[i]
  
  test "Indexed write":
    for i in 0 ..< b.len:
      # Write an adjacent value, check, then replace it.
      let
        lastVal = b[i]
        i2 = if i > 0: i - 1 else: i + 1

      b[i] = entries[i2]
      check b[i] == entries[i2]
      b[i] = lastVal
      check b[i] == entries[i]

  test "Del":
    let
      mIdx = entries.len div 2
      e1 = b.del mIdx
      e2 = b.del 0
    
    check e1 == entries[mIdx]
    check e2 == entries[0]
    check b[0] == entries[1]

    # Check all entities from entries except the deleted are present.
    for i in 1 ..< mIdx:
      check entries[i] in b
    for i in mIdx + 1 ..< entries.len:
      check entries[i] in b

  test "toDynArray":
    let
      s = @[1, 2, 3]
      da = s.toDynArray(4)
    check s == da.toSeq
