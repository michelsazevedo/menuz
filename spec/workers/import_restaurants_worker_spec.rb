# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ImportRestaurantsWorker do
  let(:json_content) do
    { restaurants: [{ name: 'Poppos', menus: [{ name: 'lunch', menu_items: [{ name: 'Burger', price: 9.00 }] }] }] }.to_json
  end

  let(:tmpfile) do
    file = Tempfile.new(['test', '.json'])
    file.write(json_content)
    file.rewind
    file
  end

  let(:import) { Import.create(status: 'pending', file_location: tmpfile.path) }

  after { tmpfile.close! if tmpfile.respond_to?(:close!) }

  describe '#perform' do
    it 'processes the import and marks it as processed' do
      described_class.new.perform(import.id)

      import.reload
      expect(import.status).to eq('processed')
      expect(import.total_records).to eq(1)
      expect(Restaurant.count).to eq(1)
    end

    it 'marks the import as processing first' do
      allow(ImportRestaurants).to receive(:call).and_return([])

      expect_any_instance_of(Import).to receive(:processing!).and_call_original

      described_class.new.perform(import.id)
    end

    context 'when import record is not found' do
      it 'returns without error' do
        expect { described_class.new.perform(999) }.not_to raise_error
      end
    end

    context 'when JSON is invalid' do
      let(:json_content) { 'not valid json' }

      it 'marks the import as failed' do
        described_class.new.perform(import.id)

        import.reload
        expect(import.status).to eq('failed')
        expect(import.error_message).to include('JSON parse error')
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(ImportRestaurants).to receive(:call).and_raise(StandardError, 'something broke')
      end

      it 'marks the import as failed and re-raises' do
        expect { described_class.new.perform(import.id) }.to raise_error(StandardError, 'something broke')

        import.reload
        expect(import.status).to eq('failed')
        expect(import.error_message).to eq('something broke')
      end
    end
  end
end
