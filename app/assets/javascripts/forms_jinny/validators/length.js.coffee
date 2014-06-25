@FormsJinny.config.validators['length'] = (record, attribute, value) ->
  # if options.tockenizer && attribute.tockenizer
  #   value = attribute.tockenizer(value)

  value_length = value.length

  return wrong_length: @options.is if @options.is and not (value_length is @options.is)
  return too_short: @options.minimum if @options.minimum and not (value_length >= @options.minimum)
  return too_long: @options.maximum if @options.maximum and not (value_length <= @options.maximum)
  return too_short: @options.within.min if @options.within and not (value_length >= @options.within.min )
  return too_long: @options.within.max if @options.within and not (value_length <= @options.within.max )