@FormsJinny.utils = {} unless @FormsJinny.utils
@FormsJinny.utils.compareValues = (v1, v2) ->
    if $.isArray(v1)
      return false unless $.isArray(v2)
      return false unless v1.length == v2.length
      s1 = v1.sort()
      s2 = v2.sort()
      return false unless a is s2[i] for a, i in v1
      return true
    else
      return v1 is v2