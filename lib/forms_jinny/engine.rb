module FormsJinny
  class Engine < ::Rails::Engine
    isolate_namespace FormsJinny

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end
  end

  extend ActiveSupport::Autoload
  autoload :Jinny
  autoload :StandardConfig
  autoload :ActionView
  autoload :MetadataBuilder


  #class << self; attr_reader :jinny; end

  def self.setup
    @@jinny = Jinny.new

    StandardConfig.configure(jinny)
    yield(jinny) if block_given?
    ::ActionView::Base.send(:include, FormsJinny::ActionView::ActionViewPatch)
    ::ActionView::Helpers::FormBuilder.send(:include, FormsJinny::ActionView::FormBuilderPatch)
  end

  def self.jinny
    @@jinny
  end

  def self.warning(msg)
    p "FormsJinny WARNING: #{msg}"
  end

end
