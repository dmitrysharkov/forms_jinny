class Form

  constructor: (@form, options) ->
    @setupEnvinronment(options)
    @setupRootRecord()
    @setupFormEvents()
    @setupElementEvents()
    @setupExportedStates()

    $(@form).data().formsJinnyForm = this
    @root.init()


  @allControlTags = 'input, select, textarea'

  @skipThis = (element) ->
    elementData = $(element).data()
    not (elementData.formsJinnyModel and  elementData.formsJinnyMethod)

  setupEnvinronment: (options)->
    metadata_str = $('script.js-forms-jinny-metadata', @form).text()[7..-7]
    @env = new FormsJinny.Environment(metadata_str, options)
    @collectRailsHiddens()

  setupRootRecord: ->
    @root = new FormsJinny.Record(@env)
    $('input, select, textarea', @form).each (index, element) =>
      @root.addElement(element) unless Form.skipThis(element)

  setupFormEvents: ->
    $(@form).on 'form:validate.formsJinny', (event) => @validate()
    $(@form).on 'form:update.formsJinny', (event) => @update()

    $(@form).on 'submit', (event) =>
      unless @validateSyncWithoutNotification()
        event.preventDefault()
        @notifyCleanup()
        @notifyFail()

  setupElementEvents: ->
    for action, trigger of @env.config.events.element
      do(action) =>
        for ev, filters of trigger
          $(@form).on ev, filters.join(','), (event) ->
             if attr = $(this).data().formsJinnyAttribute
               attr[action](this)

  setupExportedStates: ->
    @root.addExportedState(value, path) for path, value of @env.metadata.export

  collectRailsHiddens: ->
    hash = {}
    $('div:first input[type="hidden"]', @form).each (index, el) ->
      hash[$(el).attr('name')] = $(el).attr('value')
    @env.railsHiddens = hash


  wasValueChanged: -> @root.wasValueChanged()

  validateSyncWithoutNotification: -> @root.validateSync()


  update: -> @validate() if @wasValueChanged()

  validate: ->
    @notifyCleanup()
    @root.validate()
    @notifyUpdate()

  hasErrors: -> @root.hasErrors()

  notify: (eventName, params = null) -> @env.notifier.notify(@form, 'form', 'validation', eventName, params)

  notifyFail: () -> @notify('fail')

  notifyPass: () -> @notify('pass')

  notifyCleanup: () -> @notify('cleanup')

  notyfyUpdate: (element) -> if @hasErrors() then @notifyFail() else @notifyPass(element)


@FormsJinny.Form = Form