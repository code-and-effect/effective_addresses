$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require 'effective_addresses/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "effective_addresses"
  s.version     = EffectiveAddresses::VERSION
  s.authors     = ["Code and Effect"]
  s.email       = ["info@codeandeffect.com"]
  s.homepage    = "https://github.com/code-and-effect/effective_addresses"
  s.summary     = "Extend any ActiveRecord object to have one or more named addresses. Includes a geographic region-aware custom form input backed by Carmen."
  s.description = "Extend any ActiveRecord object to have one or more named addresses. Includes a geographic region-aware custom form input backed by Carmen."
  s.licenses    = ['MIT']

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", [">= 3.2.0"]
  s.add_dependency "carmen"
  s.add_dependency "carmen-rails"
  s.add_dependency "coffee-rails"
  s.add_dependency "haml-rails"

  s.add_development_dependency "rspec-rails", '~> 3.0'
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "sqlite3"

  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "guard-livereload"

  s.add_development_dependency "pry"
  s.add_development_dependency "pry-stack_explorer"
  s.add_development_dependency "pry-byebug"


end

