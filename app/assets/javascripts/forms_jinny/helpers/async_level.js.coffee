AsyncLevel =
  none: 0
  attr: 1
  record: 2
  recusive: 3
  max: (l1, l2) -> if AsyncLevel[l1] > AsyncLevel[l2] then l1 else l2
  findMax: (array) ->
    m = 'none'
    m = @max(m, a) for a in array
    if m == 'none' then null else m

@FormsJinny.AsyncLevel = AsyncLevel