EffectiveAddresses.setup do |config|
  # Database table name to store addresses in.  Default is :addresses
  config.addresses_table_name = :addresses

  # Display Full Name on Address forms, and validate presence by default
  # (can be overridden on a per address basis)
  config.use_full_name = true

  # Country codes to display in country_select dropdowns.
  config.country_codes = :all #
  #config.country_codes = ['US', 'CA'] # Or you can be more selective...

  # Select these countries ontop of the others
  config.country_codes_priority = ['US', 'CA'] # Leave empty array for no priority countries

  # SimpleForm Options
  # This Hash of options will be passed into any simple_form_for() calls
  config.simple_form_options = {}

  # config.simple_form_options = {
  #   :html => {:class => 'form-horizontal'},
  #   :wrapper => :horizontal_form,
  #   :wrapper_mappings => {
  #     :boolean => :horizontal_boolean,
  #     :check_boxes => :horizontal_radio_and_checkboxes,
  #     :radio_buttons => :horizontal_radio_and_checkboxes
  #   }
  # }

end
