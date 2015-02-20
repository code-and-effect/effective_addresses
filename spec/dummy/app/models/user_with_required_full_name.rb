class UserWithRequiredFullName < User
  acts_as_addressable :billing => {:presence => false, :use_full_name => true}, :shipping => false
end
