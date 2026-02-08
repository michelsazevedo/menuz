# frozen_string_literal: true

FactoryBot.define do
  factory :menu do
    name { FFaker::Food.fruit }
    description { FFaker::Lorem.sentence }
    restaurant_id { nil }

    trait :with_menu_items do
      transient do
        menu_items_count { 3 }
      end

      after(:create) do |menu, evaluator|
        evaluator.menu_items_count.times do
          menu.add_menu_item(create(:menu_item).save)
        end
      end
    end
  end
end
