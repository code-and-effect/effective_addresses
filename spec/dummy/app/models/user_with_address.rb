class UserWithAddress < User
  acts_as_addressable :billing, :shipping
end
