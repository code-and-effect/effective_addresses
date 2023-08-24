require 'test_helper'

class AddressesTest < ActiveSupport::TestCase
  test 'is valid' do
    address = build_effective_address
    assert address.valid?
  end
end
