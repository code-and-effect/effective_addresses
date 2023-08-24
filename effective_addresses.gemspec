$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'effective_addresses/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'effective_addresses'
  s.version     = EffectiveAddresses::VERSION
  s.authors     = ['Code and Effect']
  s.email       = ['info@codeandeffect.com']
  s.homepage    = 'https://github.com/code-and-effect/effective_addresses'
  s.summary     = 'Extend any ActiveRecord object to have one or more named addresses. Includes a geographic region-aware custom form input backed by Carmen.'
  s.description = 'Extend any ActiveRecord object to have one or more named addresses. Includes a geographic region-aware custom form input backed by Carmen.'
  s.licenses    = ['MIT']

  s.files = Dir['{app,config,db,lib}/**/*'] + ['MIT-LICENSE', 'README.md']

  s.add_dependency 'rails'
  s.add_dependency 'effective_resources'
  s.add_dependency 'carmen'
  s.add_dependency 'coffee-rails'

  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'devise'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'effective_test_bot'
  s.add_development_dependency 'effective_developer' # Optional but suggested
  s.add_development_dependency 'psych', '< 4'
end
