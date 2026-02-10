# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Importer do
  let(:json_content) do
    { restaurants: [{ name: 'Poppos', menus: [{ name: 'lunch', menu_items: [{ name: 'Burger', price: 9.00 }] }] }] }.to_json
  end

  let(:tmpfile) do
    file = Tempfile.new(['test', '.json'])
    file.write(json_content)
    file.rewind
    file
  end

  let(:file_hash) { { filename: 'restaurants.json', tempfile: tmpfile } }

  after { tmpfile.close! if tmpfile.respond_to?(:close!) }

  describe '.call' do
    context 'when file is nil' do
      it 'returns failure' do
        result = described_class.call(file: nil)

        expect(result.success?).to be false
        expect(result.error[:file]).to include('Is required')
      end
    end

    context 'when file extension is not .json' do
      let(:tmpfile) do
        file = Tempfile.new(['test', '.csv'])
        file.write('data')
        file.rewind
        file
      end
      let(:file_hash) { { filename: 'restaurants.csv', tempfile: tmpfile } }

      it 'returns failure' do
        result = described_class.call(file: file_hash)

        expect(result.success?).to be false
        expect(result.error[:file]).to include('Invalid file extension, only .json is allowed')
      end
    end

    context 'when file is too large' do
      before do
        allow(tmpfile).to receive(:size).and_return(11 * 1024 * 1024)
      end

      it 'returns failure' do
        result = described_class.call(file: file_hash)

        expect(result.success?).to be false
        expect(result.error[:file]).to include('Is too large, max 10MB')
      end
    end

    context 'with a valid file' do
      it 'creates an import record' do
        expect { described_class.call(file: file_hash) }.to change(Import, :count).by(1)
      end

      it 'returns success with import data' do
        result = described_class.call(file: file_hash)

        expect(result).to be_success
        expect(result.value[:status]).to eq('pending')
        expect(result.value[:file_location]).to include('restaurants.json')
      end

      it 'enqueues an ImportRestaurantsWorker job' do
        described_class.call(file: file_hash)

        expect(ImportRestaurantsWorker.jobs.size).to eq(1)
      end
    end
  end
end
