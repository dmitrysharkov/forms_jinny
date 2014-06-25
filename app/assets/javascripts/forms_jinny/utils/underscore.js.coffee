@FormsJinny.utils = {} unless @FormsJinny.utils
@FormsJinny.utils.underscore = (s) ->
  new_s = s[0].toLowerCase()
  for i in [1..s.length-1]
    if s[i] >= 'A' and s[i] <= 'Z'
      new_s += '_' + s[i].toLowerCase()
    else
      new_s += s[i]
  new_s


