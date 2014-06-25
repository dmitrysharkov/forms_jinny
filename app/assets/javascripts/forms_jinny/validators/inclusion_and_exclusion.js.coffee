get_range = (options) ->
  options.in or options.within

array_includes_value = (arr, value) ->
  strValue = String(value)
  for a in arr
    return true if String(a) is strValue
  false

range_includes_value = (range, value) ->
  if typeof range.min is 'number'
    nValue = Number(value)
    Number(range.min) <= nValue and nValue <= Number(range.max)
  else
    strValue = String(value)
    String(range.min) <= strValue and strValue <= String(range.max)

something_includes_value = (something, value) ->
  if $.isArray(something)
    array_includes_value(something, value)
  else if $.isPlainObject(something) and something.min? and something.max?
    range_includes_value(something, value)
  else
    null

includes_value = (record, range, value) ->
  res = something_includes_value(range, value)
  unless res?
    dyRange = record.evaluate(range)
    res = something_includes_value(range, value)
    unless res?
      console.log "Can't interpret range", range
      throw "Can't interpret range"
  res

@FormsJinny.config.validators.inclusion = (record, attribute, value)->
  range = get_range(@options)
  return 'inclusion' unless includes_value(record, range, value)

@FormsJinny.config.validators.exclusion = (record, attribute, value)->
  range = get_range(@options)
  return 'exclusion' if includes_value(record, range, value)