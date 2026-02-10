# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RestaurantsController, type: :controller do
  describe 'GET /' do
    it 'returns http success' do
      get '/'
      expect(last_response.status).to be_eql(200)
    end

    it 'returns a list of restaurants' do
      create(:restaurant).save

      get '/'
      body = Oj.load(last_response.body)

      expect(body['data'].length).to be_eql(1)
    end
  end

  describe 'GET /:id' do
    it 'returns the restaurant when found' do
      restaurant = create(:restaurant).save

      get "/#{restaurant.id}"
      body = Oj.load(last_response.body)

      expect(last_response.status).to be_eql(200)
      expect(body['data']['name']).to be_eql(restaurant.name)
    end

    it 'returns 404 when not found' do
      get '/42'

      expect(last_response.status).to be_eql(404)
    end
  end

  describe 'GET /:id/menus' do
    it 'returns menus for a restaurant' do
      restaurant = create(:restaurant).save
      create(:menu, restaurant_id: restaurant.id).save

      get "/#{restaurant.id}/menus"
      body = Oj.load(last_response.body)

      expect(last_response.status).to be_eql(200)
      expect(body['data'].length).to be_eql(1)
    end

    it 'returns 404 when restaurant not found' do
      get '/42/menus'

      expect(last_response.status).to be_eql(404)
    end
  end

  describe 'POST /import' do
    context 'with valid file' do
      let(:service) { double('Importer') }
      let(:import_data) { { id: 1, status: 'pending', file_location: '/tmp/test.json' } }

      before do
        allow(service).to receive(:success).and_yield(import_data)
        allow(service).to receive(:failure)

        allow(Importer).to receive(:call).and_yield(service)
        post '/import', file: Rack::Test::UploadedFile.new(StringIO.new('{}'), 'application/json', false, original_filename: 'test.json')
      end

      it 'returns a 202 status code' do
        expect(last_response.status).to eq(202)
      end
    end

    context 'with invalid file' do
      let(:service) { double('Importer') }
      let(:errors) { { file: ['invalid file extension, only .json is allowed'] } }

      before do
        allow(service).to receive(:success)
        allow(service).to receive(:failure).and_yield(errors)

        allow(Importer).to receive(:call).and_yield(service)
        post '/import', file: Rack::Test::UploadedFile.new(StringIO.new('data'), 'text/csv', false, original_filename: 'test.csv')
      end

      it 'returns a 422 status code' do
        expect(last_response.status).to eq(422)
      end
    end
  end

  describe 'POST /' do
    context 'with valid restaurant' do
      let(:record) { create(:restaurant) }
      let(:data) { { name: 'Gardens', location: 'João Pessoa, Brazil' }.to_json }
      let(:service) { double('CreateRestaurant') }

      before do
        allow(service).to receive(:success).and_yield(record)
        allow(service).to receive(:failure)

        allow(CreateRestaurant).to receive(:call).and_yield(service)
        post '/', data, { 'CONTENT_TYPE' => 'application/json' }
      end

      it 'returns a 200 status code' do
        expect(last_response.status).to eq(201)
      end

      it 'returns the post data in JSON' do
        response_body = Oj.load(last_response.body)

        expect(response_body['data']).to eq(Oj.load(record.to_json))
        expect(response_body['errors']).to be_nil
      end
    end

    context 'with invalid restaurant' do
      let(:data) { { name: '', location: 'João Pessoa, Brazil' }.to_json }
      let(:service) { double('CreateRestaurant') }
      let(:errors) { { name: ['is not present'] } }

      before do
        allow(service).to receive(:success)
        allow(service).to receive(:failure).and_yield(errors)

        allow(CreateRestaurant).to receive(:call).and_yield(service)
        post '/', data, { 'CONTENT_TYPE' => 'application/json' }
      end

      it 'returns a 422 status code' do
        expect(last_response.status).to eq(422)
      end

      it 'returns the error message in JSON' do
        response_body = Oj.load(last_response.body, symbolize_names: true)

        expect(response_body).to eq(data: nil, errors: errors)
      end
    end
  end
end
