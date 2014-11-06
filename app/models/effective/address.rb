require 'carmen'

module Effective
  class Address < ActiveRecord::Base
    self.table_name = EffectiveAddresses.addresses_table_name.to_s

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
        value = (Carmen::Country.coded(country_code).subregions.named(state_string) rescue nil) || Carmen::Country.coded(country_code).subregions.coded(state_string.try(:upcase))
        self.state_code = value.code if value.present?
      else
        Rails.logger.info 'No country set.  Try calling country= before state='
        puts 'No country set.  Try calling country= before state='
      end
    end
    alias_method :province=, :state=

    def postal_code_looks_canadian?
      postal_code.gsub(/ /, '').strip.match(/^\D{1}\d{1}\D{1}\-?\d{1}\D{1}\d{1}$/).present? rescue false # Matches T5T2T1 or T5T-2T1
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
      !address1.present? and !address2.present? and !city.present? and !state_code.present? and !country_code.present? and !postal_code.present?
    end

    def to_s
      output = ''
      output += "#{full_name}\n" if full_name.present?
      output += "#{address1}\n" if address1.present?
      output += "#{address2}\n" if address2.present?
      output += [city.presence, state.presence].compact.join(', ')
      output += '\n' if city.present? || state.present?
      output += [country.presence, postal_code.presence].compact.join(', ')
    end

    def to_html
      to_s.gsub(/\n/, '<br>').html_safe
    end
  end
end
