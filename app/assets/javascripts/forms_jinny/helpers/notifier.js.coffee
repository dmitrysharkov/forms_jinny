class Notifier
  constructor: (@config) ->

  notify: (target, subject, topic, name, params) ->
    validation_tirgges =  @config.triggers[subject][topic]
    trigger =
      if validation_tirgges
        if $.isPlainObject(validation_tirgges)
          validation_tirgges[name]
        else
          true
      else
        false

    if callback = @config.callbacks[subject][topic][name]
      response = callback.apply(target, params)
      trigger = true if response is true
      trigger = false if response is false

    $(target).trigger("#{ subject }:#{ topic }:#{ name }.formsJinny", params) if trigger


@FormsJinny.Notifier = Notifier