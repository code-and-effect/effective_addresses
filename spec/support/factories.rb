require 'factory_girl'

FactoryGirl.define do
  factory :address, :class => Effective::Address do
    category 'billing'
    full_name nil
    sequence(:address1) { |n| "1234#{n} Fake Street" }
    city 'San Antonio'
    state_code 'TX'
    country_code 'US'
    postal_code '92387'
  end

  factory :address_with_full_name, :class => Effective::Address do
    category 'billing'
    full_name 'Peter Pan'
    sequence(:address1) { |n| "1234#{n} Fake Street" }
    city 'San Antonio'
    state_code 'TX'
    country_code 'US'
    postal_code '92387'
  end

  factory :user do
    sequence(:email) { |n| "user_#{n}@effective_addresses.test"}
    sequence(:first_name) { |n| "First Name #{n}"}
    sequence(:last_name) { |n| "Last Name #{n}"}
  end

  factory :user_with_required_address do
    sequence(:email) { |n| "user_#{n}@effective_addresses.test"}
    sequence(:first_name) { |n| "First Name #{n}"}
    sequence(:last_name) { |n| "Last Name #{n}"}
  end

  factory :user_with_required_full_name do
    sequence(:email) { |n| "user_#{n}@effective_addresses.test"}
    sequence(:first_name) { |n| "First Name #{n}"}
    sequence(:last_name) { |n| "Last Name #{n}"}
  end

  factory :user_with_required_address_and_full_name do
    sequence(:email) { |n| "user_#{n}@effective_addresses.test"}
    sequence(:first_name) { |n| "First Name #{n}"}
    sequence(:last_name) { |n| "Last Name #{n}"}
  end
end
