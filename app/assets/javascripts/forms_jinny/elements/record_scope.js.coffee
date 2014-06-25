class RecordScope
  constructor: (@record) ->
    for namesource in [@record.properties, @record.exportedState, @record.meta.methods]
      @_register(name) for name of namesource

  $: (name) ->
    if method = @record.meta.methods[name]
      method.call(this)
    else if match = /(\w+)_changed\?/.exec(name)
      @record.properties[match[1]].isChanged()
    else if @record.properties[name]
      if @record.properties[name] instanceof Attribute then  @record.properties[name].value() else @record.properties[name]
    else if @record.exportedState[name]
      @record.exportedState[name]
    else throw "Can not resolve method #{name} in the record with model #{ @meta.name }"

  _evaluate: (str) -> eval(str)

  _register: (name) ->
    @[name] = -> @$(name)
    if match = /^([^\?]+)\?$/.exec(name)
      @["is_#{ match[1] }"] = -> @$(name)


@FormsJinny.RecordScope = RecordScope