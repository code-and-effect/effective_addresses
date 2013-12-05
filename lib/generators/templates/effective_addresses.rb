EffectiveAddresses.setup do |config|
  # Database table name to store addresses in.  Default is :addresses
  config.addresses_table_name = :addresses

  # Country codes to display in country_select dropdowns.
  config.country_codes = :all #
  config.country_codes_priority = ['US', 'CA'] # Leave empty array for no priority countries

  # Or you can be more selective...
  #config.country_codes = ['US', 'CA']
end
