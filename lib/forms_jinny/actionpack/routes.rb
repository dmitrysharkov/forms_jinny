module ActionDispatch::Routing
  class Mapper
    def forms_jinny
      path_prefix = FormsJinny.jinny.async_validation_path_prefix
      controller_path = 'forms_jinny/actionpack/async_validation'
      mathods_map = {
        validate_new_attribute: 'new/:attribute',
        validate_attribute:     ':id/:attribute',
      }

      mathods_map.each do |method, path|
        match "#{ path_prefix }/:model/#{ path }",  to: "#{ controller_path }##{ method }", via: [:post], as: "forms_jinny_#{ method }"
      end
    end
  end
end