class UserWithSingularAddress < User
  acts_as_addressable :billing => {:singular => true}, :shipping => false
end
