module FormsJinny
  class Jinny
    attr_reader :view_methods_to_patch, :validators_info

    attr_accessor :async_validation_path_prefix

    def initialize
      @view_methods_to_patch = []
      @validators_info = {}
      @current_validators_namespace = nil
      @async_validation_path_prefix = 'forms_jinny'
    end

    def patch_view(*methods)
      @view_methods_to_patch += methods
    end

    def validator(name, **meta)
      meta[:msg] ||= name.to_sym
      @validators_info[validator_name_to_constant(name)] = meta
    end

    def validators_in(namespace, &block)
      @current_validators_namespace = namespace
      instance_exec(&block)
      @current_validators_namespace = nil
    end


    def panic(message)
      p "FormsJinny PANIC: #{ message }"
    end

    def metadata_buider
      @metadata_buider ||= MetadataBuilder.new(validators_info)
    end

    private

    def validator_name_to_constant(name)
      "#{ @current_validators_namespace }::#{ name.to_s.classify }Validator".constantize
    end
  end
end