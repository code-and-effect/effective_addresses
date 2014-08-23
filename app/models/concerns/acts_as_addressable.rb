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
    has_many :addresses, :as => :addressable, :class_name => "Effective::Address", :dependent => :delete_all

    # Setup validations and methods
    categories = @acts_as_addressable_opts.try(:flatten) || []
    if categories.first.kind_of?(Hash) # We were passed some validation requirements
      categories = categories.first

      categories.each do |category, validation| # billing, shipping
        category = category.to_s.gsub('_address', '')

        self.send(:define_method, "#{category}_address") { effective_address(category) }
        self.send(:define_method, "#{category}_addresses") { effective_addresses(category) }
        self.send(:define_method, "#{category}_address=") { |atts| set_effective_address(category, atts) }

        validates "#{category}_address", :effective_address_valid => true

        if validation.kind_of?(Hash)
          validates "#{category}_address", :effective_address_presence => validation[:presence]
          validates "#{category}_address", :effective_address_full_name_presence => validation[:use_full_name] || EffectiveAddresses.use_full_name
        elsif validation == true
          validates "#{category}_address", :effective_address_presence => true
          validates "#{category}_address", :effective_address_full_name_presence => EffectiveAddresses.use_full_name
        end
      end
    else
      categories.each do |category|
        category = category.to_s.gsub('_address', '')

        self.send(:define_method, "#{category}_address") { effective_address(category) }
        self.send(:define_method, "#{category}_addresses") { effective_addresses(category) }
        self.send(:define_method, "#{category}_address=") { |atts| set_effective_address(category, atts) }

        validates "#{category}_address", :effective_address_valid => true
        validates "#{category}_address", :effective_address_full_name_presence => EffectiveAddresses.use_full_name
      end
    end
  end

  module ClassMethods
  end

  def effective_addresses(category)
    addresses.select { |address| address.category == category.to_s }
  end

  def effective_address(category)
    effective_addresses(category).last
  end

  def set_effective_address(category, atts)
    raise ArgumentError.new("Effective::Address #{category}_address= expecting an Effective::Address or Hash object") unless (atts.kind_of?(Effective::Address) || atts.kind_of?(Hash) || atts == nil)

    atts = HashWithIndifferentAccess.new(atts.kind_of?(Effective::Address) ? atts.attributes : atts)

    add = Effective::Address.new(
      :category     => category,
      :full_name    => atts[:full_name],
      :address1     => atts[:address1],
      :address2     => atts[:address2],
      :city         => atts[:city],
      :state_code   => atts[:state_code],
      :country_code => atts[:country_code],
      :postal_code  => atts[:postal_code]
    )

    self.addresses << add unless (add.empty? || add == effective_address(category))
  end

end

