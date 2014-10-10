require "effective_addresses/engine"
require "effective_addresses/version"
#require 'migrant'     # Required for rspec to run properly

module EffectiveAddresses

  # The following are all valid config keys
  mattr_accessor :country_codes
  mattr_accessor :country_codes_priority
  mattr_accessor :addresses_table_name
  mattr_accessor :use_full_name

  def self.setup
    yield self
  end

  def self.permitted_params
    [:address1, :address2, :city, :country_code, :state_code, :postal_code, :full_name]
  end

end
