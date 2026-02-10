# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ImportRestaurants do
  let(:payload) do
    {
      restaurants: [
        {
          name: "Poppo's Cafe",
          menus: [
            {
              name: 'lunch',
              menu_items: [
                { name: 'Burger', price: 9.00 },
                { name: 'Small Salad', price: 5.00 }
              ]
            },
            {
              name: 'dinner',
              menu_items: [
                { name: 'Burger', price: 15.00 },
                { name: 'Large Salad', price: 8.00 }
              ]
            }
          ]
        },
        {
          name: 'Casa del Poppo',
          menus: [
            {
              name: 'lunch',
              dishes: [
                { name: 'Chicken Wings', price: 9.00 },
                { name: 'Burger', price: 9.00 },
                { name: 'Chicken Wings', price: 9.00 }
              ]
            },
            {
              name: 'dinner',
              dishes: [
                { name: 'Mega Burger', price: 22.00 },
                { name: 'Lobster Mac & Cheese', price: 31.00 }
              ]
            }
          ]
        }
      ]
    }
  end

  describe '.call' do
    it 'creates restaurants with their menus and items' do
      result = described_class.call(restaurants: payload[:restaurants])

      expect(result.length).to eq(2)
      expect(Restaurant.count).to eq(2)
      expect(Menu.count).to eq(4)
    end

    it 'handles the dishes key as menu_items' do
      described_class.call(restaurants: payload[:restaurants])

      casa = Restaurant.first(name: 'Casa del Poppo')
      lunch = Menu.first(name: 'lunch', restaurant_id: casa.id)

      expect(lunch.menu_items.map(&:name)).to include('Chicken Wings')
    end

    it 'deduplicates menu items by name within a menu' do
      described_class.call(restaurants: payload[:restaurants])

      casa = Restaurant.first(name: 'Casa del Poppo')
      lunch = Menu.first(name: 'lunch', restaurant_id: casa.id)

      expect(lunch.menu_items.count { |i| i.name == 'Chicken Wings' }).to eq(1)
    end

    it 'does not duplicate existing restaurants' do
      Restaurant.create(name: "Poppo's Cafe", location: 'Downtown')

      result = described_class.call(restaurants: payload[:restaurants])

      expect(result.length).to eq(2)
      expect(Restaurant.where(name: "Poppo's Cafe").count).to eq(1)
    end

    it 'does not duplicate existing menus' do
      restaurant = Restaurant.create(name: "Poppo's Cafe", location: 'Downtown')
      Menu.create(name: 'lunch', restaurant_id: restaurant.id)

      described_class.call(restaurants: payload[:restaurants])

      expect(Menu.where(name: 'lunch', restaurant_id: restaurant.id).count).to eq(1)
    end
  end
end
