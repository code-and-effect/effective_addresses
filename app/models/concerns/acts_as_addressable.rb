# ActsAsAddressable

module ActsAsAddressable
  extend ActiveSupport::Concern

  module ActiveRecord
    def acts_as_addressable(*options)
      @acts_as_addressable_opts = options || []
      include ::ActsAsAddressable
    end
  end

  included do
    has_many :addresses, as: :addressable, class_name: 'Effective::Address', dependent: :delete_all, autosave: true

    # Normalize categories
    categories = @acts_as_addressable_opts.try(:flatten) || []

    if categories.first.kind_of?(Hash)
      categories = categories.first.transform_keys { |category| category.to_s.gsub('_address', '') }
    else
      categories = categories.map { |category| category.to_s.gsub('_address', '') }
    end

    # Categories can be either:
    # {'billing'=>{:singular=>true, :use_full_name=>false}, 'shipping'=>{:singular=>true, :use_full_name=>false}}
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
        validates "#{category}_address", presence: options.fetch(:presence, false)
        validates "#{category}_address", effective_address_full_name_presence: options.fetch(:use_full_name, EffectiveAddresses.use_full_name)
      when TrueClass, FalseClass
        validates "#{category}_address", presence: (options == true)
        validates "#{category}_address", effective_address_full_name_presence: EffectiveAddresses.use_full_name
      else
        raise 'Unexpected options. Expected a Hash or Boolean'
      end
    end

    if ((categories.try(:keys) rescue nil) || categories).include?('billing') && ((categories.try(:keys) rescue nil) || categories).include?('shipping')
      self.send(:define_method, :shipping_address_same_as_billing?) { billing_address == shipping_address }
    end

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

  def set_effective_address(category, atts)
    raise "#{category}_address= expected an Effective::Address or Hash" unless atts.kind_of?(Effective::Address) || atts.kind_of?(Hash)

    atts = (atts.kind_of?(Effective::Address) ? atts.attributes : atts).symbolize_keys

    address = Effective::Address.new(
      :category     => category.to_s,
      :full_name    => atts[:full_name],
      :address1     => atts[:address1],
      :address2     => atts[:address2],
      :city         => atts[:city],
      :state_code   => atts[:state_code],
      :country_code => atts[:country_code],
      :postal_code  => atts[:postal_code],
      :shipping_address_same_as_billing => atts[:shipping_address_same_as_billing]
    )

    if category == 'shipping' && address.shipping_address_same_as_billing? && respond_to?(:billing_address)
      address = effective_address('billing')
    end

    address == effective_address(category) ? effective_address(category) : self.addresses.build(address.attributes)
  end

  def set_singular_effective_address(category, atts)
    raise "#{category}_address= expected an Effective::Address or Hash" unless atts.kind_of?(Effective::Address) || atts.kind_of?(Hash)

    atts = (atts.kind_of?(Effective::Address) ? atts.attributes : atts).symbolize_keys

    address = Effective::Address.new(
      :category     => category.to_s,
      :full_name    => atts[:full_name],
      :address1     => atts[:address1],
      :address2     => atts[:address2],
      :city         => atts[:city],
      :state_code   => atts[:state_code],
      :country_code => atts[:country_code],
      :postal_code  => atts[:postal_code],
      :shipping_address_same_as_billing => atts[:shipping_address_same_as_billing]
    )

    if category == 'shipping' && address.shipping_address_same_as_billing? && respond_to?(:billing_address)
      address = effective_address('billing')
    end

    (effective_address(category) || self.addresses.build).tap do |existing|
      existing.category     = category.to_s
      existing.full_name    = address.full_name
      existing.address1     = address.address1
      existing.address2     = address.address2
      existing.city         = address.city
      existing.state_code   = address.state_code
      existing.country_code = address.country_code
      existing.postal_code  = address.postal_code
      existing.shipping_address_same_as_billing = address.shipping_address_same_as_billing?
    end

  end

end

