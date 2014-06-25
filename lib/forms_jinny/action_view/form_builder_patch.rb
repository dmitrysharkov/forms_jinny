module FormsJinny
  module ActionView
    module FormBuilderPatch
      def forms_jinny_export(*methods)
        methods.each do |method|
          case method
          when Symbol, String then forms_jinny_export_name(method)
          when Hash then forms_jinny_export_hash(method)
          else raise 'forms_jinny_export: only Symbol, String or Hash are allowed'
          end
        end
        nil
      end

      def forms_jinny_export_hash(hash)
        hash.each {|key, value| forms_jinny_export_pair(key, value) }
      end

      def forms_jinny_export_name(name)
        name = name.to_sym
        raise "forms_jinny_export: Unknown method #{ method }" unless @object.methods.include?(name)
        forms_jinny_export_pair(name, @object.send(name))
      end

      def forms_jinny_export_pair(key, value)
        name = "#{ @object_name }[#{ key }]"
        @template.froms_jinny_export(name, value)
      end
    end
  end
end