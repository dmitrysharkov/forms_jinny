class Record
  constructor: (@env) ->
    @properties = {}
    @exportedState = {}

  init: ->
    p.init() for n,p of @properties
    @evalScope = new FormsJinny.RecordScope(this) if @meta

  recursiveAdd: (val, nameTail, inserter) ->
    if match = /^([^\]]+)(\[\])?$/.exec(nameTail)
      @[inserter](val, match[1])
    else if match = /^([^\]]+)\[([^\]]+)\](.*)$/.exec(nameTail)
      name = match[1]
      tail = match[2] + match[3]
      @properties[name] = new FormsJinny.Record(@env) unless @properties[name]
      @properties[name].recursiveAdd(val, tail, inserter)
    else
      throw "Can't resolve the name tail #{ nameTail }"

  addElement: (element, nameTail) ->
    nameTail ||= $(element).attr('name')
    @recursiveAdd(element, nameTail, 'addAttribute')

  addAttribute: (element, name) ->
    @properties[name] = new FormsJinny.Attribute(this) unless @properties[name]
    @properties[name].addElement(element)
    $(element).data().formJinnyAttribute = @properties[name]

  addExportedState: (value, nameTail) ->
    @recursiveAdd(value, nameTail, 'addExportedStateValue')

  addExportedStateValue: (value, name) ->
    @exportedState[name] = value

  update: -> p.update() for n,p of @properties

  validate: ->
    @resetCurrentValue()
    @update()

  updateSync: ->
    res = true
    res = p.updateSync() and res for n,p of @properties
    res

  wasValueChanged: ->
    res = true
    res = p.wasValueChanged() and res for n,p of @properties
    res


  validateSync: ->
    @resetCurrentValue()
    @updateSync()

  hasErrors: ->
    res = true
    res = p.hasErrors() and res for n,p of @properties
    res

  resetCurrentValue: -> p.resetCurrentValue() for n,p of @properties

  evaluate: -> @evalScope._evaluate()

  attributes: -> (p for p in @properties when (p instanceof FormsJinny.Attribute))

  dataHash: (prefix = '') ->
    hash = {}
    name_prefix = @inputName(prefix)
    hash[a.inputName(name_prefix)] = a.val() for a in @attributes()
    hash

  inputName: (prefix)->
    underscored_name = FormsJinny.utils.underscore(@meta.name)
    if prefix then "#{ prefix }[#{ underscored_name }]" else underscored_name


@FormsJinny.Record = Record