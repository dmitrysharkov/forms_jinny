class Element
  constructor: (element) ->
    @element = $(element)

  jquery: -> @element

  getSelectValue: () -> if @element.attr('multiple') then @element.val() || [] else $element.val()

  getCheckboxValue: () -> if isArray then @collectArrayValues($form, $element, 'checked') else ($element.val() ? true : false)

  getRadioValue: () ->  if isArray then @collectArrayValues($form, $element, 'selected') else $element.val()

  getTextAreaValue: () -> @element.val() || ''

  getInputValue: () ->
    switch @element.attr('type').toLowerCase()
      when 'checkbox' then @getCheckboxValue(isArray, $form, $element)
      when 'raido' then @getRadioValue(isArray, $form, $element)
      else @element.val()

  value: ->
    switch @element.prop('tagName')
      when 'SELECT' then @getSelectValue()
      when 'TEXTAREA' then @getTextAreaValue()
      else @getInputValue()

@FormsJinny.Element = Element