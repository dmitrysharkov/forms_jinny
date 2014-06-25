module FormsJinny
  module StandardConfig
    extend ActiveSupport::Autoload
    autoload :ActionViewConfig
    autoload :ActiveModelValidatorsConfig
    autoload :ActiveRecordValidatorsConfig
    autoload :SimpleFormConfig

    def self.configure(jinny)
      [ActionViewConfig, ActiveModelValidatorsConfig, ActiveRecordValidatorsConfig].each { |c| c.configure(jinny) }
      SimpleFormConfig.configure(jinny) if defined? SimpleForm
    end
  end
end