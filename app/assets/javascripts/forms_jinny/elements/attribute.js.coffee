class Attribute
  constructor: (@record) ->
    @env = @record.env
    @elements = []
    @messages = []
    @fullMessages = []

  init: ->
    @originalValue = @value()

  isChanged: -> FormsJinny.utils.compareValues(@originalValue, @value)

  addElement: (element) ->
    $element = $(element)
    @resetMetadata($element) unless @meta
    $element.data().formsJinnyAttribute = this
    @elements.push new FormsJinny.Element($element)

  isArray: -> @elements.length > 1

  resetMetadata: ($element) ->
    elementData = $element.data()

    modelName = elementData.formsJinnyModel or (console.log $element; throw "No model name found. ELEMENT logged")
    attrName = elementData.formsJinnyMethod or (console.log $element; throw "No method name found. ELEMENT logged")

    model = @env.metadata.models[modelName] or throw "Unknown model #{ modelName }"
    @meta = model.attributes[attrName] or throw "Unknown attribute #{ modelName }.#{ attrName }"

    @record.isNew = true if elementData.formsJinnyNewRecord
    @record.id = elementData.formsJinnyRecordId if elementData.formsJinnyRecordId
    @record.meta = model

  value: ->
    if @isArray()
      (e.value() for e in @elements)
    else
      @elements[0].value()


  syncValidators: -> (v for v in @meta.validators when not v.async)
  asyncValidators: -> (v for v in @meta.validators when v.async)

  notify: (element, eventName, params = null) -> @env.notifier.notify(element, 'element', 'validation', eventName, params)

  notifyFail: (element, params) -> @notify(element, 'fail', params)

  notifyPass: (element) -> @notify(element, 'pass')

  notifyAsync: (element) -> @notify(element, 'async')

  notifyCleanup: (element) -> @notify(element, 'cleanup')

  notyfyUpdate: (element) -> if @hasErrors() then @notifyFail(element, [@messages, @fullMessages]) else @notifyPass(element)

  hasErrors: -> @messages.length > 0

  clearErrors: (element) ->
    @messages = []
    @fullMessages = []

  fullMessageFor: (message) -> @env.errorsGenerator.attributeFullError(message, this, @currentValue)


  effectiveElement: (element) -> element or @elements[0].jquery()


  prepareValidation: (element)->
    element = @effectiveElement(element)
    @clearErrors(element)
    @notifyCleanup(element)
    element

  validate: (element = null) ->
    element = @prepareValidation(element)
    pass = @validateSyncWithoutNotify(element)
    if pass
      @validateAsync(element)
    else
      @notyfyUpdate(element)

  validateSync: (element = null) ->
    element = @prepareValidation(element)
    res = @validateSyncWithoutNotify(element)
    @notyfyUpdate(element)
    return res

  wasValueChanged: ->
    newValue = @value()
    if @currentValue is undefined
      @currentValue = newValue
      return true
    else
      if FormsJinny.utils.compareValues(@currentValue, newValue)
        return false
      else
        @currentValue = newValue
        return true


  getCurrentValue: ->
    if @currentValue is undefined
      @currentValue = @value()
    @currentValue

  resetCurrentValue: -> @currentValue = undefined


  update: (element) -> @validate(element) if @wasValueChanged()

  updateSync: (element) -> @validateSync(element) if @wasValueChanged()


  validateSyncWithoutNotify: (element) ->
    for v in @syncValidators() when v.passAttributeValidator(@record, @currentValue)
      errors = v.validate(@record, this, @getCurrentValue())
      if errors
        errors = [ errors ] unless $.isArray(errors)
        @addErrors(errors, v.messages)
    return not @hasErrors()

  addErrors: (errors, messages) ->
    for err in errors
      if $.isPlainObject(err)
        @addError(e, count, messages) for e, count of err
      else
        @addError(err, null, messages)

  addError: (error, count, messages) ->
    message =  @env.errorsGenerator.attributeError(error, count, messages, this)
    @messages.push message
    @fullMessages.push @fullMessageFor(message)

  validateAsync: (element) ->
    async_level = FormsJinny.AsyncLevel.findMax(@asyncValidators().map((v) -> v.async))
    return unless async_level

    @notifyAsync(element)
    data =
      switch async_level
        when 'attr' then @dataHash()
        when 'record' then @record.dataHash()
        else  FormsJinny.panic('recursive data collecting not implemented'); null

    $.extend(data, @env.railsHiddens)

    url = @asyncValidationUrl()

    $.post(url, data).done (data) =>
      @notifyCleanup(element)
      if data.errors
        @messages = data.errors
        @fullMessages = (@fullMessageFor(e) for e in data.errors)
      else
        @clearErrors(element)
      @notyfyUpdate(element)



  dataHash: (value = null) ->
    d = {}
    d[@inputName(@record.inputName())] = value || @value()
    d

  inputName: (prefix) ->
    scalar_name = if prefix then "#{ prefix }[#{ @meta.name }]" else @meta.name
    if @isArray() then "#{ scalar_name }[]" else scalar_name


  asyncValidationUrl: ->
    id = @record.id || 'new'
    "/#{ @env.metadata.aync_validation_path }/#{ @record.meta.name }/#{ id }/#{ @meta.name }"


@FormsJinny.Attribute = Attribute