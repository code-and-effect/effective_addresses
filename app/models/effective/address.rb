# frozen_string_literal: true

module Effective
  class Address < ActiveRecord::Base
    self.table_name = EffectiveAddresses.addresses_table_name.to_s
    attr_accessor :shipping_address_same_as_billing

    POSTAL_CODE_CA = /\A[A-Z]{1}\d{1}[A-Z]{1}\ \d{1}[A-Z]{1}\d{1}\z/  # Matches 'T5Z 2B1'
    POSTAL_CODE_US = /\A\d{5}\z/ # Matches 5 digits

    belongs_to :addressable, polymorphic: true, touch: true

    effective_resource do
      category          :string

      full_name         :string
      address1          :string
      address2          :string
      address3          :string

      city              :string
      state_code        :string
      country_code      :string
      postal_code       :string

      shipping_address_same_as_billing permitted: true

      timestamps
    end

    validates :category, :address1, :city, :country_code, :postal_code, presence: true, if: Proc.new { |address| address.present? }
    validates :state_code, presence: true, if: Proc.new { |address| address.present? && (address.country_code.blank? || Carmen::Country.coded(address.country_code).try(:subregions).present?) }

    validates_format_of :postal_code, :with => POSTAL_CODE_CA,
      :if => proc { |address| Array(EffectiveAddresses.validate_postal_code_format).include?('CA') && address.country_code == 'CA' },
      :allow_blank => true,  # We're already checking for presence above
      :message => 'is an invalid Canadian postal code'

    validates_format_of :postal_code, :with => POSTAL_CODE_US,
      :if => proc { |address| Array(EffectiveAddresses.validate_postal_code_format).include?('US') && address.country_code == 'US' },
      :allow_blank => true,  # We're already checking for presence above
      :message => 'is an invalid United States zip code'

    scope :sorted, -> { order(:updated_at) }
    scope :billing, -> { where(:category => 'billing') }
    scope :shipping, -> { where(:category => 'shipping') }

    def first_name
      full_name.split(' ').first rescue full_name
    end

    def last_name
      full_name.gsub(first_name, '').strip rescue full_name
    end

    def country
      Carmen::Country.coded(country_code).name rescue ''
    end

    def state
      Carmen::Country.coded(country_code).subregions.coded(state_code).name rescue ''
    end
    alias_method :province, :state

    def country=(country_string)
      value = Carmen::Country.named(country_string) || Carmen::Country.coded(country_string.try(:upcase))
      self.country_code = value.code if value.present?
    end

    def state=(state_string)
      if country.present?
        subregions = (Carmen::Country.coded(country_code).subregions rescue nil)

        if subregions.present?
          value = subregions.named(state_string) || subregions.coded(state_string.try(:upcase))
        else
          value = nil
        end

        self.state_code = value.code if value.present?
      else
        Rails.logger.info 'No country set.  Try calling country= before state='
        puts 'No country set.  Try calling country= before state='
      end
    end
    alias_method :province=, :state=

    # If the country is Canada or US, enforce the correct postal code/zip code format
    def postal_code=(code)
      if code.presence.kind_of?(String)
        if country_code == 'CA'
          code = code.upcase.gsub(/[^A-Z0-9]/, '')
          code = code.insert(3, ' ') if code.length == 6
        elsif country_code == 'US'
          code = code.gsub(/[^0-9]/, '')
        end
      end

      super(code)
    end

    def postal_code_looks_canadian?
      postal_code.to_s.match(POSTAL_CODE_CA).present?
    end

    def postal_code_looks_american?
      postal_code.to_s.match(POSTAL_CODE_US).present?
    end

    def ==(other_address)
      self_attrs = self.attributes
      other_attrs = other_address.respond_to?(:attributes) ? other_address.attributes : {}

      [self_attrs, other_attrs].each { |attrs| attrs.except!('id', 'created_at', 'updated_at', 'addressable_type', 'addressable_id', 'category') }

      self_attrs == other_attrs
    end

    # An address may be set with a category but nothing else
    def blank?
      address1.blank? && address2.blank? && city.blank? && postal_code.blank?
    end
    alias_method :empty?, :blank?

    def present?
      !blank?
    end

    def to_s
      output = ''
      output += "#{full_name}\n" if full_name.present?
      output += "#{address1}\n" if address1.present?
      output += "#{address2}\n" if address2.present?
      output += "#{address3}\n" if respond_to?(:address3) && address3.present?
      output += [city.presence, state_code.presence, " #{postal_code.presence}"].compact.join(' ')
      output += "\n"
      output += country.to_s
      output
    end

    def to_html
      to_s.gsub(/\n/, "<br>\n").gsub('  ', '&nbsp;&nbsp;').html_safe
    end

    def shipping_address_same_as_billing?
      if defined?(::ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES)  # Rails 5
        ::ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.include?(shipping_address_same_as_billing)
      else
        ::ActiveRecord::Type::Boolean.new.cast(shipping_address_same_as_billing)
      end
    end
  end
end
