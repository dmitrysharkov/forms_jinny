PreconditionsChecker =
  passAttributeValidator: (record, value)->
    @passRecordValidator(record) and
    @passAllowBlankValidator(record, value) and
    @passAllowNilValidator(record, value)

  passRecordValidator: (record) ->
    @passIfValidator(record) and
    @passUnlessValidator(record) and
    @passActionValidator(record)

  passActionValidator: (record) ->
    if action = @options.on
      (action is 'create' and record.isNewRecord()) or (action is 'update' and not record.isNewRecord())
    else
      true

  passIfValidator: (record) ->
    if @options.if
      return false unless record.evaluate(e) for e in @options.if
    return true

  passUnlessValidator: (record) ->
    if @options.unless
      return false if record.evaluete(e) for e in @options.unless
    return true

  passAllowBlankValidator: (record, value) ->
    if @options.allow_blank
      if value instanceof Array then value.length > 0 else value
    else
      true

  passAllowNilValidator: (record, value) ->
    if @options.allow_nil
      not value is null
    else
      true

@FormsJinny.PreconditionsChecker = PreconditionsChecker