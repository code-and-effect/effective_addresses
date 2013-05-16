require "effective_addresses/engine"

module EffectiveAddresses

  # The following are all valid config keys
  mattr_accessor :country_codes

  def self.setup
    yield self
  end

end
