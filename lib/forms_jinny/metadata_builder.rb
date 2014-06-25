module FormsJinny
  class MetadataBuilder

    def initialize(validators_info)
      @validators_info = validators_info
    end


    def build(form_jinny_uses_model_method, export_values)
      metadata = {
        export: export_values || {},
        models: build_molels(form_jinny_uses_model_method),
        errors_format: I18n.t(:"errors.format", { default:  "%{attribute} %{message}", resolve: false }),
        aync_validation_path: FormsJinny.jinny.async_validation_path_prefix
      }
      if I18n.backend.respond_to?(:pluralizer_name) && I18n.backend.respond_to?(:pluralizer_rules)
        metadata[:pluralizer] = { name: I18n.backend.pluralizer_name, rules: I18n.backend.pluralizer_rules }
      end
      metadata
    end

    private


    def build_molels(form_jinny_uses_model_method)
      models = {}

      form_jinny_uses_model_method.each do |model, fields|
        model_name = model.model_name.to_s
        models[model_name] = {
          name: model_name,
          human_name: model.model_name.human,
          attributes: build_model_attributes(model, fields)
        }
      end
      models
    end

    attr_reader :validators_info

    def build_model_attributes(model, fields)
      Hash[fields.map { |f| [f, build_model_attribute(model, f)] }]
    end

    def build_model_attribute(model, field)
      {
        name: field,
        human_name: model.human_attribute_name(field),
        validators: build_attribute_validators(model, field)
      }
    end

    def build_attribute_validators(model, field)
      model.validators.select { |v| v.attributes.include?(field) }.map do |validator|
        hash = {
          name: validator_name(validator),
          options: build_validator_options(model, field, validator),
          messages: build_validator_messages(model, field, validator)
        }
        async = validators_info[validator.class][:async] if validators_info[validator.class]
        hash[:async] =  async if async

        hash
      end
    end

    def validator_name(validator)
      validator.class.to_s.split('::').last.sub(/Validator$/, '').underscore
    end

    def build_validator_options(model, field, validator)
      new_options = {}
      validator.options.each do |option, value|
        new_options[option] = case value
          when Regexp then regext_to_js(value)
          when Range then range_to_js(range)
          else value
        end

        if [:if, :unless].include?(option)
          if value.kind_of?(Array)
            new_options[option]  = value.map {|v|  build_validator_condition_value(model, field, v)  }
          else
            new_options[option] = [ build_validator_condition_value(model, field, value) ]
          end
        end
      end
      new_options
    end

    def build_validator_condition_value(model, field, value)
      case value
      when Symbol, String
        then  value.to_s.gsub(/[[:alpha:]]\w+[!?]?\(?/) { |s| if s[-1] != '(' then "$('#{ s }')" else "$('#{ s[0..-2] }'," end }
                        .gsub(/,\)/,')')
                        .gsub(/([^.]|^)$\(/,' this.$(')
                        .strip
      else FormsJinny.panic("Can't translate block condition for #{ model }.#{ field }") ; nil
      end
    end

    def regext_to_js(regexp)
      refined = regexp.inspect
        .sub('\\A','^')
        .sub('\\Z','$')
        .sub('\\z','$')
        .sub(/^\//,'')
        .sub(/\/[a-z]*$/,'')
        .gsub(/\(\?#.+\)/, '')
        .gsub(/\(\?-\w+:/,'(')
        .gsub(/\s/,'')
      Regexp.new(refined).inspect
    end

    def range_to_js(range)
      { min: range.first, max: range.last }
    end

    def build_validator_messages(model, field, validator)
      if message = validator.options[:message]
        build_custom_message(model, field, validator, message)
      else
        build_default_messages(model, field, validator)
      end
    end

    def build_custom_message(model, field, validator, message)
      if message.is_a(Symbol)
        build_message_for_type(model, field, validator, message)
      else
        message.to_s
      end
    end

    def build_default_messages(model, field, validator)
      Hash[get_appliable_message_types(validator).map { |t| [t, build_message_for_type(model, field, validator, t)] }]
    end

    def get_appliable_message_types(validator)
      case msg_info = validators_info[validator.class][:msg]
      when Array then fileter_messages_array(msg_info, validator.options)
      when Symbol then [msg_info]
      else [:invalid]
      end
    end

    def fileter_messages_array(msg_types_array, options)
      msg_types_array.map do |msg|
        case msg
        when Hash then filter_message_form_options(msg, options)
        when Symbol then msg
        else nil
        end
      end.select { |msg| msg }
    end

    def filter_message_form_options(msg, options)

      type = msg.keys.first
      message_applid_to_options = msg[type]
      message_applid_to_options = [ message_applid_to_options ] unless message_applid_to_options.kind_of?(Array)

      type if message_applid_to_options & options.keys
    end

    def build_message_for_type(model, attribute, validator, type)
      if model.respond_to?(:i18n_scope)
        defaults = model.lookup_ancestors.map do |klass|
          [ :"#{ model.i18n_scope }.errors.models.#{ klass.model_name.i18n_key }.attributes.#{ attribute }.#{ type }",
            :"#{ model.i18n_scope }.errors.models.#{ klass.model_name.i18n_key }.#{ type }" ]
        end
      else
        defaults = []
      end

      defaults << :"#{ type }"
      defaults << :"#{ model.i18n_scope }.errors.messages.#{ type }" if model.respond_to?(:i18n_scope)
      defaults << :"errors.attributes.#{ attribute }.#{ type }"
      defaults << :"errors.messages.#{ type }"

      defaults.compact!
      defaults.flatten!


      message = find_message_for_type(defaults)
      message
    end

    def find_message_for_type(types)
      types.each do |type|
        msg = I18n.backend.send(:lookup, I18n.locale, type, [], { resolve: false })
        return msg if msg
      end
      'is invalid'
    end
  end
end