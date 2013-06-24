$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "effective_addresses/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "effective_addresses"
  s.version     = EffectiveAddresses::VERSION
  s.authors     = ["Code and Effect"]
  s.email       = ["info@codeandeffect.com"]
  s.homepage    = "https://github.com/code-and-effect/effective_addresses"
  s.summary     = "Effectively manage address CRUD."
  s.description = "Provides helper methods for dealing with a has_many :addresses relationship as a single method. Includes full validations for addresses with multiple categories. Includes a formtastic helper method to create/update the address of a parent object. Uses the Carmen gem so when a Country is selected, an AJAX request populates the State/Province fields as appropriate."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails"
  s.add_dependency "carmen"
  s.add_dependency "carmen-rails"
  s.add_dependency "coffee-rails"
  s.add_dependency "formtastic"
  s.add_dependency "haml"
  s.add_dependency "migrant"

  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "psych"
end

