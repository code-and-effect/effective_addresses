require 'carmen-rails'

module EffectiveAddressesHelper
  def effective_address_fields(form, method = 'billing', options = {})
    method = (method.to_s.include?('_address') ? method.to_s : "#{method}_address")

    opts = {:f => form, :method => method, :skip_full_name => false}.merge(options)

    if form.kind_of?(SimpleForm::FormBuilder)
      render :partial => 'effective/addresses/address_fields_simple_form', :locals => opts
    elsif form.kind_of?(Formtastic::FormBuilder)
      render :partial => 'effective/addresses/address_fields_formtastic', :locals => opts
    else
      raise 'Unsupported FormBuilder.  You must use formtastic or simpleform. Sorry.'
    end

  end
end

