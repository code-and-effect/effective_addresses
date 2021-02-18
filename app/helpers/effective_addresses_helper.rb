module EffectiveAddressesHelper
  def effective_address_fields(form, method = 'billing', options = {})
    method = (method.to_s.include?('_address') ? method.to_s : "#{method}_address")

    required = (form.object._validators[method.to_sym].any? { |v| v.kind_of?(ActiveRecord::Validations::PresenceValidator) && (v.options[:if].blank? || (v.options[:if].respond_to?(:call) ? f.object.instance_exec(&v.options[:if]) : v.options[:if])) } rescue true)
    use_full_name = form.object._validators[method.to_sym].any? { |v| v.kind_of?(EffectiveAddressFullNamePresenceValidator) }

    address = form.object.send(method) || form.object.addresses.build(category: method.to_s.gsub('_address', ''))
    effective_address_pre_select(address) if address.new_record?

    opts = { required: required, use_full_name: use_full_name, field_order: [:full_name, :address1, :address2, :city, :country_code, :state_code, :postal_code] }.merge(options).merge({:f => form, :address => address, :method => method})

    case form.class.name
    when 'Effective::FormBuilder'
      render partial: 'effective/addresses/form_with', locals: opts
    when 'SimpleForm::FormBuilder'
      render partial: 'effective/addresses/simple_form', locals: opts
    when 'Formtastic::FormBuilder'
      render partial: 'effective/addresses/formtastic', locals: opts
    else
      raise 'Unsupported FormBuilder.  You must use formtastic, simpleform or effective_bootstrap. Sorry.'
    end
  end

  def effective_address_pre_select(address)
    if EffectiveAddresses.pre_selected_country.present?
      address.country = EffectiveAddresses.pre_selected_country
      address.state = EffectiveAddresses.pre_selected_state if EffectiveAddresses.pre_selected_state.present?
    elsif defined?(Geocoder) && request.location.present?
      location = request.location
      address.country = location.country_code
      address.state = location.state_code
      address.postal_code = location.postal_code
      address.city = location.city
    end
  end

  def effective_address_regions_collection(regions = nil, resource: nil)
    if regions.present?
      countries = regions
    elsif EffectiveAddresses.country_codes == :all
      countries = Carmen::Country.all
    else
      countries = Carmen::Country.all.select { |c| (EffectiveAddresses.country_codes || []).include?(c.code) }
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
