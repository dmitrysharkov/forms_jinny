@FormsJinny.utils = {} unless @FormsJinny.utils
@FormsJinny.utils.interpolate = (s, values) ->
    parts = []
    i = 0

    while i < s.length
      open_index =  s.indexOf('%{', i)
      if open_index < 0
        parts.push s.substring(i, s.length)
        break
      else
        parts.push s.substring(i, open_index)
        i = open_index + 2
        close_index = s.indexOf('}', i)
        close_index = s.length if close_index < 0
        key = s.substring(i, close_index).trim()
        if val = values[key]
          parts.push val
        else
          parts.push "%{ #{key} }"
        i = close_index + 1
    parts.join('')


