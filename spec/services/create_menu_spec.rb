# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CreateMenu do
  let(:restaurant) { create(:restaurant).save }

  describe '.call' do
    context 'with valid params' do
      it 'creates a menu' do
        result = described_class.call(name: 'Lunch', description: 'Daily lunch', restaurant_id: restaurant.id)

        expect(result).to be_success
        expect(result.value[:name]).to eq('Lunch')
      end
    end

    context 'with invalid params' do
      it 'returns failure' do
        result = described_class.call(name: '', restaurant_id: nil)

        expect(result.success?).to be false
      end
    end
  end
end
