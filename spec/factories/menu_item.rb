# frozen_string_literal: true

FactoryBot.define do
  factory :menu_item do
    name { FFaker::Food.ingredient }
    description { FFaker::Lorem.sentence }
    price { FFaker::Number.decimal }
  end
end
