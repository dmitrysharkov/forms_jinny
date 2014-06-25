value_present = (value)->
  value and (not $.isArray(value) or ($.isArray(value) and  value.length > 0))

@FormsJinny.config.validators.presence = (record, attribute, value) ->
  return 'blank' unless value_present(value)

@FormsJinny.config.validators.absence = (record, attribute, value) ->
  return 'present' if value_present(value)
