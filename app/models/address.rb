class Address < ActiveRecord::Base
  belongs_to :addressable, :polymorphic => true, :touch => true

  structure do
    category        :string, :validates => [:presence, :inclusion => { :in => %w(billing shipping primary secondary address)}]

    full_name       :string, :validates => [:presence]
    address1        :string, :validates => [:presence]
    address2        :string
    city            :string, :validates => [:presence]
    state_code      :string, :validates => [:presence]
    country_code    :string, :validates => [:presence]
    postal_code     :string, :validates => [:presence]
    timestamps
  end

  default_scope order(:updated_at)

  scope :billing_addresses, -> { where(:category => 'billing') }
  scope :shipping_addresses, -> { where(:category => 'shipping') }

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

  def province
    Carmen::Country.coded(country_code).subregions.coded(state_code).name rescue ''
  end

  def country=(country_string)
    value = Carmen::Country.named(country_string) || Carmen::Country.coded(country_string.try(:upcase))
    self.country_code = value.code if value.present?
  end

  def state=(state_string)
    if country.present?
      value = Carmen::Country.coded(country_code).subregions.named(state_string) || Carmen::Country.coded(country_code).subregions.coded(state_string.try(:upcase))
      self.state_code = value.code if value.present?
    else
      Rails.logger.info 'No country set.  Try calling country= before state='
      puts 'No country set.  Try calling country= before state='
    end
  end

  def postal_code_looks_canadian?
    postal_code.gsub(/ /, '').strip.match(/^\D{1}\d{1}\D{1}\-?\d{1}\D{1}\d{1}$/).present? rescue false # Matches T5T2T1 or T5T-2T1
  end

  def ==(other_address)
    self_attrs = self.attributes
    other_attrs = other_address.respond_to?(:attributes) ? other_address.attributes : {}

    [self_attrs, other_attrs].each { |attrs| attrs.except!('id', 'created_at', 'updated_at', 'addressable_type', 'addressable_id', 'address2') }

    self_attrs == other_attrs
  end

  # An address may be set with a category but nothing else
  # This is considered empty
  def empty?
    !full_name.present? and !address1.present? and !address2.present? and !city.present? and !state_code.present? and !country_code.present? and !postal_code.present?
  end

  def to_s
    output = "#{full_name}\n"
    output += "#{address1}\n"
    output += "#{address2}\n" if address2.present?
    output += "#{city}, #{state}\n"
    output += "#{country}, #{postal_code}"
  end

  def to_html
    to_s.gsub(/\n/, '<br>').html_safe
  end
end
