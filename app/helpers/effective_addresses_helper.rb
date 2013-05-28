require 'carmen-rails'

module EffectiveAddressesHelper
  def address_fields(form, options = {})
    opts = {:f => form, :category => 'address', :skip_full_name => false}.merge(options)

    case opts[:category]
    when 'shipping'
      opts[:name] = 'Shipping Address'
      opts[:method] = :shipping_address
    when 'billing'
      opts[:name] = 'Billing Address'
      opts[:method] = :billing_address
    when 'primary'
      opts[:name] = 'Primary Address'
      opts[:method] = :primary_address
    when 'secondary'
      opts[:name] = 'Secondary Address'
      opts[:method] = :secondary_address
    else
      opts[:name] = 'Address'
      opts[:method] = :address
    end

    render :partial => 'addresses/address_fields', :locals => opts
  end
end
