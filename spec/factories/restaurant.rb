# frozen_string_literal: true

FactoryBot.define do
  factory :restaurant do
    name { FFaker::Company.name }
    location { FFaker::Address.city }  
  end
end
