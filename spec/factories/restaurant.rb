# frozen_string_literal: true

FactoryBot.define do
  factory :restaurant do
    name { Faker::Name.unique.first_name }
    phone { Faker::PhoneNumber.phone_number }
    phone_country_code { Faker::PhoneNumber.country_code }
    website { Faker::Internet.url }
    amount_per_guest { "$#{Faker::Commerce.price}" }
    category { Faker::Lorem.word }
    toast_email { Faker::Internet.email }
    toast_password { Faker::Internet.password }
    toast_authenticator_key { Faker::Internet.password }
    toast_url { Faker::Internet.url }
    addr_lat { Faker::Number.decimal(l_digits: 3, r_digits: 3) }
    addr_lng { Faker::Number.decimal(l_digits: 3, r_digits: 3) }
    addr_street { Faker::Address.street_name }
    addr_city { Faker::Address.city }
    addr_state { Faker::Address.state }
    addr_code { Faker::Address.postcode }
    addr_country { Faker::Address.country }
    background_color { Faker::Color.hex_color }
    cuisine
    association :additional_cuisine_one, factory: :cuisine
    association :additional_cuisine_two, factory: :cuisine

    association :restaurant_group

    after :create do |restaurant|
      business_day = FactoryBot.create(:business_day)
      FactoryBot.create_list(:business_hour, 2, business_day:, restaurant:)
    end

    trait :skip_callbacks do
      after(:build) { |restaurant| restaurant.class.skip_callback(:save, :before, :add_spanish_translations) }
      after(:create) { |restaurant| restaurant.class.set_callback(:save, :before, :add_spanish_translations) }
    end
  end
end
