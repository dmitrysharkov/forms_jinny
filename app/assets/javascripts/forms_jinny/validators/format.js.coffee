@FormsJinny.config.validators.format = (record, attribute, value)->
  if @options['with']
    r = new RegExp(@options['with'][1..-2])
    return 'invalid' unless r.test(value)

  if @options['without']
    r = new RegExp(@options['without'][1..-2])
    return 'invalid' if r.test(value)
