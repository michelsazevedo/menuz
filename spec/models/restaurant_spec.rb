# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Restaurant do
  describe '.search' do
    before do
      create(:restaurant, name: 'Gardens')
      create(:restaurant, name: 'Verde Green')
    end

    it 'returns all records when no query is given' do
      results = described_class.search
      expect(results.all.length).to eq(2)
    end

    it 'filters by name' do
      results = described_class.search(q: 'gardens')
      expect(results.all.length).to eq(1)
    end

    it 'returns the correct page' do
      results = described_class.search(page: 2, per_page: 1)
      expect(results.all.length).to eq(1)
    end
  end
end
