class ErrorsGenerator
  constructor: (@pluralizer, @errorsFormat) ->

  pluralizeError: (error, count) ->
    if error instanceof Object
      if @pluralizer
        error = @pluralizer.pluralize(error, count)
      else
        if error.other
          error = error.other
        else
          for v,err of error
            return err
    else
      error

  normalizeError: (error, count, messages, data) ->
    error = messages[error] if messages[error]
    error = @pluralizeError(error, count)
    FormsJinny.utils.interpolate(error, data)


  attributeError: (error, count, messages, attribute, value) ->
    @normalizeError error, count, messages,
      attribute: attribute.meta.human_name,
      model: attribute.record.meta.human_name
      value: value
      count: count

  attributeFullError: (message, attribute) ->
    FormsJinny.utils.interpolate @errorsFormat,
      message: message,
      attribute: attribute.meta.human_name,
      model: attribute.record.meta.human_name


@FormsJinny.ErrorsGenerator = ErrorsGenerator