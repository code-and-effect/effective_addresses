class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  acts_as_addressable :billing

  # effective_addresses_organization_user
  # effective_addresses_user

  def to_s
    "#{first_name} #{last_name}"
  end

end
