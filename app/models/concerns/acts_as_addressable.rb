# ActsAsAddressable
#
# This module creates .billing_address, .shipping_address and .address methods
# it tricks a has_many relationship into singleton methods
#
# Mark your model with 'acts_as_addressable'
#
# there are no additional migrations needed for this module to work.
#
# By default, addresses are NOT required
#
# If you want to validate presence, please mark your model
# acts_as_addressable :require_billing => true, :require_address => true, :require_shipping => true
#
# Please see app/views/admin/users/_form.html.haml for an example of how to use this in a formtastic form
#

module ActsAsAddressable
  extend ActiveSupport::Concern

  module ActiveRecord
    def acts_as_addressable(options = {})
      @acts_as_addressable_opts = {:require_shipping => false, :require_billing => false, :require_primary => false, :require_secondary => false, :require_address => false}.merge(options)
      include ::ActsAsAddressable
    end
  end

  included do
    has_many :addresses, :as => :addressable, :class_name => "Address", :dependent => :delete_all

    validates_with BillingAddressValidator if @acts_as_addressable_opts[:require_billing]
  end

  module ClassMethods
  end

  def single_addresses
    addresses.select { |address| address.category == 'address' }
  end

  def address
    single_addresses.last
  end

  def address=(address_atts)
    add = (address_atts.kind_of?(Address) ? address_atts.dup : Address.new(address_atts))
    add.category = 'address'
    addresses << add if !add.empty? and !(add == address)
  end

  def shipping_addresses
    addresses.select { |address| address.category == 'shipping' }
  end

  def shipping_address
    shipping_addresses.last
  end

  def shipping_address=(address_atts)
    add = (address_atts.kind_of?(Address) ? address_atts.dup : Address.new(address_atts))
    add.category = 'shipping'
    addresses << add if !add.empty? and !(add == shipping_address)
  end

  def billing_addresses
    addresses.select { |address| address.category == 'billing' }
  end

  def billing_address
    billing_addresses.last
  end

  def billing_address=(address_atts)
    add = (address_atts.kind_of?(Address) ? address_atts.dup : Address.new(address_atts))
    add.category = 'billing'
    addresses << add if !add.empty? and !(add == billing_address)
  end

  def primary_addresses
    addresses.select { |address| address.category == 'primary' }
  end

  def primary_address
    primary_addresses.last
  end

  def primary_address=(address_atts)
    add = (address_atts.kind_of?(Address) ? address_atts.dup : Address.new(address_atts))
    add.category = 'primary'
    addresses << add if !add.empty? and !(add == primary_address)
  end

  def secondary_addresses
    addresses.select { |address| address.category == 'secondary' }
  end

  def secondary_address
    secondary_addresses.last
  end

  def secondary_address=(address_atts)
    add = (address_atts.kind_of?(Address) ? address_atts.dup : Address.new(address_atts))
    add.category = 'secondary'
    addresses << add if !add.empty? and !(add == secondary_address)
  end
end

