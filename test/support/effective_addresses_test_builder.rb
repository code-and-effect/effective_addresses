module EffectiveAddressesTestBuilder

  def build_effective_address(addressable: nil)
    address = Effective::Address.new(
      category: 'billing',
      address1: '123 Fake Street',
      city: 'Edmonton',
      country: 'CA',
      province: 'AB',
      postal_code: 'H0H0H0'
    )

    address.assign_attributes(addressable: addressable || build_user)

    address
  end

  def build_user
    @user_index ||= 0
    @user_index += 1

    User.new(
      email: "user#{@user_index}@example.com",
      password: 'rubicon2020',
      password_confirmation: 'rubicon2020',
      first_name: 'Test',
      last_name: 'User'
    )
  end

  def build_user_with_address
    user = build_user()

    user.addresses.build(
      addressable: user,
      category: 'billing',
      full_name: 'Test User',
      address1: '1234 Fake Street',
      city: 'Victoria',
      state_code: 'BC',
      country_code: 'CA',
      postal_code: 'H0H0H0'
    )

    user.save!
    user
  end

end
