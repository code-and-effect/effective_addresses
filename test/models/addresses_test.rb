require 'test_helper'

class AddressesTest < ActiveSupport::TestCase
  class Recipient
    include ActiveModel::Model
    attr_accessor :billing_address
    validates :billing_address, effective_address_full_name_presence: true
  end

  test 'is valid' do
    address = build_effective_address
    assert address.valid?
  end
  test 'an invalid address invalidates its owner with a symbolic error' do
    user = build_user
    address = build_effective_address(addressable: user)
    address.postal_code = 'invalid'
    user.billing_address = address

    refute user.valid?
    assert user.errors.added?(:billing_address, :invalid)
    assert_equal 'is an invalid Canadian postal code', user.billing_address.errors[:postal_code].first
  end

  test 'required recipient name adds a blank error and invalidates the owner' do
    address = build_effective_address
    recipient = Recipient.new(billing_address: address)

    refute recipient.valid?
    assert recipient.errors.added?(:billing_address, :invalid)
    assert address.errors.added?(:full_name, :blank)
    address.full_name = 'Named Recipient'
    assert recipient.valid?
  end

  test 'postal format errors use the active locale' do
    I18n.backend.translate(:en, 'activerecord.errors.models.effective/address.attributes.postal_code.invalid_us_zip_code')
    I18n.backend.store_translations(:en, activerecord: { errors: { models: {
      'effective/address' => { attributes: { postal_code: { invalid_us_zip_code: 'Translated ZIP error' } } }
    } } })
    address = build_effective_address
    address.country_code = 'US'
    address.state_code = 'WA'
    address.postal_code = '1234'

    refute address.valid?
    assert_equal 'Translated ZIP error', address.errors[:postal_code].first
    address.postal_code = '98101'
    assert address.valid?
  ensure
    I18n.backend.reload!
  end
end
