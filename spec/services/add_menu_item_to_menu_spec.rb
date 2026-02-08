# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AddMenuItemToMenu do
  let(:restaurant) { create(:restaurant).save }
  let(:menu) { create(:menu, restaurant_id: restaurant.id).save }

  describe '.call' do
    context 'with valid params' do
      it 'creates and adds multiple menu items to the menu' do
        items = [
          { name: 'Caesar Salad', price: 12.99 },
          { name: 'Grilled Salmon', price: 24.50 }
        ]

        result = described_class.call(menu_id: menu.id, menu_items: items)

        expect(result).to be_success
        expect(result.value[:menu_items].length).to eq(2)
      end
    end

    context 'when menu item name already exists' do
      before { MenuItem.create(name: 'Burger', price: 10.00) }

      it 'upserts the price and adds to menu' do
        result = described_class.call(menu_id: menu.id, menu_items: [{ name: 'Burger', price: 15.00 }])

        expect(result).to be_success
        expect(MenuItem.first(name: 'Burger').price).to eq(15.00)
      end
    end

    context 'when menu not found' do
      it 'returns failure' do
        result = described_class.call(menu_id: 999, menu_items: [{ name: 'Salad', price: 9.99 }])

        expect(result.success?).to be false
        expect(result.error).to eq(menu: ['not found'])
      end
    end

    context 'with invalid menu item attributes' do
      it 'returns failure with indexed errors' do
        result = described_class.call(menu_id: menu.id, menu_items: [{ name: '', price: nil }])

        expect(result.success?).to be false
        expect(result.error.first[:index]).to eq(0)
        expect(result.error.first[:errors]).to be_a(Hash)
      end
    end
  end
end
