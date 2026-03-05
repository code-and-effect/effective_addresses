require_relative "boot"

require "rails/all"
require 'sprockets/rails'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'haml'
require 'wicked'
require 'devise'

require "effective_test_bot"

module Dummy
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])
    config.active_record.use_yaml_unsafe_load = true
    config.active_job.queue_adapter = :inline
  end
end
