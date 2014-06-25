@FormsJinny.newError = (name, count) ->
  if count
    err = {}
    err[name] = count
    err
  else
    name