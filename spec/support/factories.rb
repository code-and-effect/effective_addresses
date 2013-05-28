require 'factory_girl'

FactoryGirl.define do
  factory :address, :class => Effective::Address do
    category 'shipping'
    full_name 'Peter Pan'
    sequence(:address1) { |n| "1234#{n} Fake Street" }
    city 'San Antonio'
    state_code 'TX'
    country_code 'US'
    postal_code '92387'
  end
end
