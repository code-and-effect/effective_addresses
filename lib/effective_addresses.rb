require 'carmen'
require 'effective_resources'
require 'effective_addresses/engine'
require 'effective_addresses/version'

module EffectiveAddresses

  def self.config_keys
    [
      :addresses_table_name,
      :country_codes,
      :country_codes_priority,
      :use_full_name,
      :use_address3,
      :simple_form_options,
      :validate_postal_code_format,
      :pre_selected_country,
      :pre_selected_state
    ]
  end

  include EffectiveGem

  def self.permitted_params
    [
      :address1, :address2, :address3, :city, :country_code, :state_code, :postal_code,
      :full_name, :shipping_address_same_as_billing
    ]
  end

end
