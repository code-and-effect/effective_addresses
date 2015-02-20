class UserWithRequiredAddress < User
  acts_as_addressable :billing => {:presence => true, :use_full_name => false}, :shipping => false
end
