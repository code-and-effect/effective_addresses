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
# acts_as_addressable :billing => true, :shipping => false
#
# Please see app/views/admin/users/_form.html.haml for an example of how to use this in a formtastic form
#

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

        if validation == true
          validates "#{category}_address", :effective_address_presence => true
        end
      end
    else
      categories.each do |category|
        category = category.to_s.gsub('_address', '')

        self.send(:define_method, "#{category}_address") { effective_address(category) }
        self.send(:define_method, "#{category}_addresses") { effective_addresses(category) }
        self.send(:define_method, "#{category}_address=") { |atts| set_effective_address(category, atts) }

        validates "#{category}_address", :effective_address_valid => true
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
    add = (atts.kind_of?(Effective::Address) ? atts.dup : Effective::Address.new(atts))
    add.category = category.to_s
    self.addresses << add unless (add.empty? || add == effective_address(category))
  end

end

