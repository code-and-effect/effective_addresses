require 'carmen-rails'

module EffectiveAddressesHelper
  def effective_address_fields(form, method = 'billing', options = {})
    method = (method.to_s.include?('_address') ? method.to_s : "#{method}_address")

    opts = {:f => form, :method => method, :skip_full_name => false}.merge(options)

    render :partial => 'effective/addresses/address_fields', :locals => opts
  end
end

