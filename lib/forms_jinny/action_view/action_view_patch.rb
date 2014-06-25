module FormsJinny
  module ActionView
    module ActionViewPatch

      def self.included(base)
        FormsJinny.jinny.view_methods_to_patch.each do |view_method|
          replacement_text = <<-eos
            def #{ view_method }(*a)
              forms_jinny_do_magic(a)
              super(*a)
            end
          eos
          base.class_eval(replacement_text , __FILE__, __LINE__)
        end
      end

      def form_for(record, options = {}, &block)
        new_block = lambda do |f|
          content = block.call(f)
          content << forms_jinny_render_script_tag_with_metadata if forms_jinny_metadata_collected?
        end

        forms_jinny_set_form_options(options)
        super(record, options, &new_block)
      end

      def froms_jinny_export(key, value)
        @form_jinny_export_hash ||= {}
        key = key.to_sym
        @form_jinny_export_hash[key] = value
      end

      private

      def forms_jinny_set_form_options(options)
        options[:html] ||= {}
        (options[:html][:class] ||= '') << ' js-forms-jinny-form'
      end

      def forms_jinny_do_magic(params)
        method = forms_jinny_extract_method(params)
        object = forms_jinny_extract_object(params)
        if method && object
          forms_jinny_put_jinny_attributes(params, object, method)
          forms_jinny_uses_model_method(forms_jinny_record_or_class_to_model_class(object), method)
        end
      end

      def forms_jinny_extract_method(params)
         params[1] if params.size > 1
      end

      def forms_jinny_extract_object(params)
        params.select { |param| param.kind_of?(Hash) && param[:object] }.map {|p| p[:object]}.first
      end

      def forms_jinny_put_jinny_attributes(params, object, method)
        i = params.size - 1
        while i >= 0
          param = params[i]
          if param.kind_of?(Hash) && param[:class] #html props are here!
            param.merge!(forms_jinny_extra_attributes(object, method))
            return
          end
          i = i - 1
        end
      end

      def forms_jinny_extra_attributes(object, method)
        model = forms_jinny_record_or_class_to_model_class(object)
        extra = { 'data-forms-jinny-model' => model.model_name, 'data-forms-jinny-method' => method.to_s }
        extra['data-forms-jinny-new-record'] = true if object.respond_to?(:new_record?) && object.new_record?
        extra['data-forms-jinny-record-id'] = object.id if object.respond_to?(:id)
        extra
      end

      def forms_jinny_record_or_class_to_model_class(record_or_class)
        (record_or_class.is_a?(Class) ? record_or_class : convert_to_model(record_or_class).class)
      end

      def forms_jinny_uses_model_method(model, method)
        @form_jinny_uses_model_method ||= {}
        @form_jinny_uses_model_method[model] = [] unless @form_jinny_uses_model_method[model]
        @form_jinny_uses_model_method[model] << method.to_sym
      end

      def forms_jinny_metadata_collected?
        @form_jinny_uses_model_method ? true : false
      end

      def forms_jinny_render_script_tag_with_metadata
        metadata = FormsJinny.jinny.metadata_buider.build(@form_jinny_uses_model_method, @form_jinny_export_hash)
        %{<script class="js-forms-jinny-metadata"><!--\n//(#{ metadata.to_json })\n// --></script>}.html_safe
      end

    end
  end
end