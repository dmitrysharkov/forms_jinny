class Environment
  constructor: (metadata_str, config) ->
    @config = config or {}
    @setMetadata(metadata_str)
    @resetPluralizer()
    @setConfig(config)
    @resetModels()
    @resetAttrValidators()
    @resetErrorsGenerator()
    @resetNotifier()

  setMetadata: (metadata_str) ->
    @metadata = eval(metadata_str)

  resetPluralizer: ->
    if @metadata.pluralizer && window[@metadata.pluralizer.name]
      @pluralizer = new window[@metadata.pluralizer.name](@metadata.pluralizer.rules)

  setConfig: (config) -> @config = $.extend(config, FormsJinny.config)

  resetModels: ->
    @models = @metadata.models

    m.methods = {} for k, m of @models

    if @config.models
      for name, model of @config.models
        @models[name] = @newModel() unless @models[name]
        @models[name].methods = model.methods if model.methods


  newModel: -> { attributes: {}, methods: {} }

  resetAttrValidators: ->
    for modelName, model of @models
      for attrName, attr of model.attributes
        attr.validators = [] unless attr.validators
        for validator in attr.validators
          unless validator.async
            validator.validate = @config.validators[validator.name]
            throw "No sync validator implementation for #{ validator.name }" unless validator.validate
          $.extend(validator, FormsJinny.PreconditionsChecker)

  resetErrorsGenerator: -> @errorsGenerator = new FormsJinny.ErrorsGenerator(@pluralizer, @metadata.errors_format)

  resetNotifier: -> @notifier = new FormsJinny.Notifier(@config)

@FormsJinny.Environment = Environment

