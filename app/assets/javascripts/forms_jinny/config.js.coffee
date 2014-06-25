inputTypes = ['color', 'date', 'datetime', 'datetime-local', 'email', 'file', 'image', 'month', 'number', 'password', 'range', 'search', 'tel', 'text', 'time', 'url', 'week']
allControlTags = ['input', 'select', 'textarea']

@FormsJinny =
  config:
    validators: {}
    models: {}

    callbacks:
      element:
        validation: {}
      form:
        validation: {}

    triggers:
      element:
        validation:
          pass: true
          fail: true
          async: true
          cleanup: true

      form:
        validation:
          pass: true
          fail: true
          async: true

    events:
      element:
        validate:
          'element:validate.formsJinny': allControlTags
        update:
          focusout: ("input[type=\"#{ t }\"]" for t in inputTypes).concat(['select'])
          change: ['input[type="checkbox"', 'input[type="radio"]', 'select']
          'element:validate.formsJinny': allControlTags

    setModelMethod: (model, method, func) ->
      @getModel(model).methods[method] = func

    getModel: (name) ->
      @models[name] = { methods: {} } unless @models[name]
      @models[name]

  setup: (func)->
    func(@config)


