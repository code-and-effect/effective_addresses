require 'carmen'

module Effective
  class Address < ActiveRecord::Base
    self.table_name = EffectiveAddresses.addresses_table_name.to_s

    POSTAL_CODE_CA = /\A[A-Z]{1}\d{1}[A-Z]{1}\ \d{1}[A-Z]{1}\d{1}\z/  # Matches 'T5Z 2B1'
    POSTAL_CODE_US = /\A\d{5}\z/ # Matches 5 digits

    belongs_to :addressable, :polymorphic => true, :touch => true

    structure do
      category        :string, :validates => [:presence]

      full_name       :string

      address1        :string, :validates => [:presence]
      address2        :string

      city            :string, :validates => [:presence]

      state_code      :string
      country_code    :string, :validates => [:presence]

      postal_code     :string, :validates => [:presence]

      timestamps
    end

    validates_presence_of :state_code, :if => Proc.new { |address| address.country_code.blank? || Carmen::Country.coded(address.country_code).try(:subregions).present? }

    validates_format_of :postal_code, :with => POSTAL_CODE_CA,
      :if => proc { |address| Array(EffectiveAddresses.validate_postal_code_format).include?('CA') && address.country_code == 'CA' },
      :allow_blank => true,  # We're already checking for presence above
      :message => 'is an invalid Canadian postal code'

    validates_format_of :postal_code, :with => POSTAL_CODE_US,
      :if => proc { |address| Array(EffectiveAddresses.validate_postal_code_format).include?('US') && address.country_code == 'US' },
      :allow_blank => true,  # We're already checking for presence above
      :message => 'is an invalid United States zip code'

    default_scope -> { order(:updated_at) }

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

      [self_attrs, other_attrs].each { |attrs| attrs.except!('id', 'created_at', 'updated_at', 'addressable_type', 'addressable_id') }

      self_attrs == other_attrs
    end

    # An address may be set with a category but nothing else
    # This is considered empty
    def empty?
      !address1.present? && !address2.present? && !city.present? && !postal_code.present?
    end

    def to_s
      output = ''
      output += "#{full_name}\n" if full_name.present?
      output += "#{address1}\n" if address1.present?
      output += "#{address2}\n" if address2.present?
      output += [city.presence, state_code.presence, " #{postal_code.presence}"].compact.join(' ')
      output += "\n"
      output += country.to_s
      output
    end

    def to_html
      to_s.gsub(/\n/, "<br>\n").gsub('  ', '&nbsp;&nbsp;').html_safe
    end
  end
end
