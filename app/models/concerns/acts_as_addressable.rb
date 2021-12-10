# frozen_string_literal: true

# ActsAsAddressable

module ActsAsAddressable
  extend ActiveSupport::Concern

  module Base
    def acts_as_addressable(*options)
      @acts_as_addressable_opts = options || []
      include ::ActsAsAddressable
    end
  end

  included do
    has_many :addresses, -> { order(:updated_at) }, as: :addressable, class_name: 'Effective::Address', dependent: :delete_all, autosave: true

    # Normalize categories
    categories = @acts_as_addressable_opts.try(:flatten) || []

    if categories.first.kind_of?(Hash)
      categories = categories.first.transform_keys { |category| category.to_s.gsub('_address', '') }
    else
      categories = categories.map { |category| category.to_s.gsub('_address', '') }
    end

    # Categories can be either:
    # {'billing'=>{:singular=>true}, 'shipping'=>{:singular=>true}}
    # or
    # {'billing' => true, 'shipping' => true}
    # or
    # ['billing', 'shipping']

    categories.each do |category, options = {}|
      # Define our two getter methods
      self.send(:define_method, "#{category}_address") { effective_address(category) }
      self.send(:define_method, "#{category}_addresses") { effective_addresses(category) }

      # Define our setter method
      if options.kind_of?(Hash) && options[:singular]
        self.send(:define_method, "#{category}_address=") { |atts| set_singular_effective_address(category, atts) }
      else
        self.send(:define_method, "#{category}_address=") { |atts| set_effective_address(category, atts) }
      end

      # Consider validations now
      validates "#{category}_address", effective_address_valid: true

      case options
      when Hash
        validates("#{category}_address", presence: true) if options[:presence]
        validates("#{category}_address", effective_address_full_name_presence: true) if options[:use_full_name]
      when TrueClass
        validates "#{category}_address", presence: true
        validates "#{category}_address", effective_address_full_name_presence: true, if: -> { EffectiveAddresses.use_full_name }
      when FalseClass
        # Nothing to do
      else
        raise 'Unexpected options. Expected a Hash or Boolean'
      end
    end

    # [:billing_address, :shipping_address]
    address_names = (categories.respond_to?(:keys) ? categories.keys : categories).map { |category| (category.to_s + '_address').to_sym }

    if address_names.include?(:billing_address) && address_names.include?(:shipping_address)
      self.send(:define_method, :shipping_address_same_as_billing?) { billing_address == shipping_address }
    end

    self.send(:define_method, :effective_address_names) { address_names }
  end

  module ClassMethods
  end

  def effective_addresses(category)
    category = category.to_s
    addresses.select { |address| address.category == category }
  end

  def effective_address(category)
    effective_addresses(category).last
  end

  def set_effective_address(category, obj)
    raise "#{category}_address= expected an Effective::Address or Hash" unless obj.kind_of?(Effective::Address) || obj.kind_of?(Hash)

    address = (obj.kind_of?(Effective::Address) ? obj : Effective::Address.new(obj))

    if category == 'shipping' && address.shipping_address_same_as_billing? && respond_to?(:billing_address)
      address = effective_address('billing')
    end

    # Prevents duplicates from being created
    return effective_address(category) if address == effective_address(category)

    (self.addresses.build).tap do |existing|
      existing.addressable  = self
      existing.category     = category.to_s
      existing.full_name    = address.full_name
      existing.address1     = address.address1
      existing.address2     = address.address2
      existing.address3     = address.address3 if address.respond_to?(:address3)
      existing.city         = address.city
      existing.state_code   = address.state_code
      existing.country_code = address.country_code
      existing.postal_code  = address.postal_code
      existing.shipping_address_same_as_billing = address.shipping_address_same_as_billing?
    end
  end

  def set_singular_effective_address(category, obj)
    raise "#{category}_address= expected an Effective::Address or Hash" unless obj.kind_of?(Effective::Address) || obj.kind_of?(Hash)

    address = (obj.kind_of?(Effective::Address) ? obj : Effective::Address.new(obj))

    if category == 'shipping' && address.shipping_address_same_as_billing? && respond_to?(:billing_address)
      address = effective_address('billing')
    end

    # This wouldn't create duplicates anyway
    return effective_address(category) if address == effective_address(category)

    (effective_address(category) || self.addresses.build).tap do |existing|
      existing.addressable  = self
      existing.category     = category.to_s
      existing.full_name    = address.full_name
      existing.address1     = address.address1
      existing.address2     = address.address2
      existing.address3     = address.address3 if address.respond_to?(:address3)
      existing.city         = address.city
      existing.state_code   = address.state_code
      existing.country_code = address.country_code
      existing.postal_code  = address.postal_code
      existing.shipping_address_same_as_billing = address.shipping_address_same_as_billing?
    end
  end

end
