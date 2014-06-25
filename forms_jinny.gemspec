$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "forms_jinny/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "forms_jinny"
  s.version     = FormsJinny::VERSION
  s.authors     = ["Dmitry Sharkov"]
  s.email       = ["dmitry.sharkov@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "Pushes rails forms validators to client side."
  s.description = "Pushes rails forms validators to client side."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1.1"

  s.add_development_dependency "sqlite3"
end
