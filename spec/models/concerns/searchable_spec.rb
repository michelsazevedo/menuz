# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Searchable do
  let(:searchable_class) do
    Class.new do
      def self.dataset; end

      extend Searchable::ClassMethods
      searchable :name, :title
    end
  end

  let(:dataset) { double('dataset') }
  let(:paginated) { double('paginated') }

  before do
    allow(searchable_class).to receive(:dataset).and_return(dataset)
  end

  describe '.searchable_columns' do
    it 'returns the configured searchable columns' do
      expect(searchable_class.searchable_columns).to eq(%i[name title])
    end
  end

  describe '.search' do
    context 'without a query' do
      it 'returns all records paginated' do
        allow(dataset).to receive(:paginate).with(1, 20).and_return(paginated)

        expect(searchable_class.search).to eq(paginated)
      end
    end

    context 'with a query' do
      it 'filters records by searchable columns' do
        filtered = double('filtered')

        allow(dataset).to receive(:where).and_return(filtered)
        allow(filtered).to receive(:paginate).with(1, 20).and_return(paginated)

        expect(searchable_class.search(q: 'test')).to eq(paginated)
      end

      it 'builds ILIKE conditions for each searchable column' do
        filtered = double('filtered')

        expect(dataset).to receive(:where) do |condition|
          expect(condition.args.length).to eq(2)
          filtered
        end

        allow(filtered).to receive(:paginate).and_return(paginated)

        searchable_class.search(q: 'test')
      end
    end

    context 'with pagination' do
      it 'respects page and per_page parameters' do
        allow(dataset).to receive(:paginate).with(2, 10).and_return(paginated)

        expect(searchable_class.search(page: 2, per_page: 10)).to eq(paginated)
      end
    end
  end
end
