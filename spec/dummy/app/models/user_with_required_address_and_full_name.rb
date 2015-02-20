class UserWithRequiredAddressAndFullName < User
  acts_as_addressable :billing => {:presence => true, :use_full_name => true}, :shipping => false
end
