# frozen_string_literal: true

module EffectiveAddressesHelper
  def effective_address_fields(form, method = 'billing', options = {})
    method = (method.to_s.include?('_address') ? method.to_s : "#{method}_address")

    required = (form.object._validators[method.to_sym].any? { |v| v.kind_of?(ActiveRecord::Validations::PresenceValidator) && (v.options[:if].blank? || (v.options[:if].respond_to?(:call) ? f.object.instance_exec(&v.options[:if]) : v.options[:if])) } rescue true)

    address = form.object.send(method) || form.object.addresses.build(category: method.to_s.gsub('_address', ''))

    effective_address_pre_select(address) if address.new_record?

    opts = { required: required, field_order: [:full_name, :address1, :address2, :city, :country_code, :state_code, :postal_code] }.merge(options).merge({:f => form, :address => address, :method => method})

    case form.class.name
    when 'Effective::FormBuilder'
      render partial: 'effective/addresses/form_with', locals: opts
    when 'Effective::TableBuilder'
      form.effective_address(method, options)
    when 'SimpleForm::FormBuilder'
      render partial: 'effective/addresses/simple_form', locals: opts
    when 'Formtastic::FormBuilder'
      render partial: 'effective/addresses/formtastic', locals: opts
    else
      raise 'Unsupported FormBuilder.  You must use formtastic, simpleform or effective_bootstrap. Sorry.'
    end
  end

  def effective_address_pre_select(address)
    if address.country.blank? && EffectiveAddresses.pre_selected_country.present?
      address.country = EffectiveAddresses.pre_selected_country
    end

    if address.state.blank? && EffectiveAddresses.pre_selected_state.present?
      address.state = EffectiveAddresses.pre_selected_state
    end

    if defined?(Geocoder) && request.try(:location).present?
      location = request.location
      address.country = location.country_code
      address.state = location.state_code
      address.postal_code = location.postal_code
      address.city = location.city
    end

    address
  end

  def effective_address_regions_collection(regions = nil, resource: nil)
    countries = if regions.present?
      regions
    elsif EffectiveAddresses.country_codes == :all
      Carmen::Country.all
    else
      Carmen::Country.all.select { |c| (EffectiveAddresses.country_codes || []).include?(c.code) }
    end

    if regions.blank? && EffectiveAddresses.country_codes_priority.present?
      countries = countries.reject { |c| EffectiveAddresses.country_codes_priority.include?(c.code) }
    end

    countries = countries.map { |c| [c.name, c.code] }.sort! { |a, b| a.first <=> b.first }

    if regions.blank? && EffectiveAddresses.country_codes_priority.present?
      countries.unshift(*
        EffectiveAddresses.country_codes_priority.map do |code|
          country = Carmen::Country.coded(code)
          [country.name, country.code]
        end + [['-------------------', '-', disabled: :disabled]]
      )
    end

    # Special behaviour if the address has CAN, we treat it as CA
    if regions.blank? && resource.present? && resource.country_code == 'CAN'
      ca = countries.index { |_, code| code == 'CA' }

      if ca.present?
        countries[ca] = ['Canada', 'CAN']
      end
    end

    countries
  end
end
