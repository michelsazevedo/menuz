# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MenusController, type: :controller do
  describe 'GET /:id' do
    it 'returns the menu when found' do
      restaurant = create(:restaurant).save
      menu = create(:menu, restaurant_id: restaurant.id).save

      get "/#{menu.id}"
      body = Oj.load(last_response.body)

      expect(last_response.status).to be_eql(200)
      expect(body['data']['name']).to be_eql(menu.name)
      expect(body['data']['menu_items']).to be_an(Array)
    end

    it 'returns 404 when not found' do
      get '/42'

      expect(last_response.status).to be_eql(404)
    end
  end

  describe 'POST /' do
    context 'with valid menu' do
      let(:restaurant) { create(:restaurant).save }
      let(:record) { create(:menu, restaurant_id: restaurant.id) }
      let(:data) { { name: 'Lunch', description: 'Lunch specials', restaurant_id: restaurant.id }.to_json }
      let(:service) { double('CreateMenu') }

      before do
        allow(service).to receive(:success).and_yield(record)
        allow(service).to receive(:failure)

        allow(CreateMenu).to receive(:call).and_yield(service)
        post '/', data, { 'CONTENT_TYPE' => 'application/json' }
      end

      it 'returns a 201 status code' do
        expect(last_response.status).to eq(201)
      end

      it 'returns the menu data in JSON' do
        response_body = Oj.load(last_response.body)

        expect(response_body['data']).to eq(Oj.load(record.to_json))
        expect(response_body['errors']).to be_nil
      end
    end

    context 'with invalid menu' do
      let(:data) { { name: '', restaurant_id: nil }.to_json }
      let(:service) { double('CreateMenu') }
      let(:errors) { { name: ['is not present'] } }

      before do
        allow(service).to receive(:success)
        allow(service).to receive(:failure).and_yield(errors)

        allow(CreateMenu).to receive(:call).and_yield(service)
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

  describe 'POST /:id/menu_items' do
    context 'when adding menu items successfully' do
      let(:restaurant) { create(:restaurant).save }
      let(:menu) { create(:menu, restaurant_id: restaurant.id).save }
      let(:data) { { menu_items: [{ name: 'Caesar Salad', price: 12.99 }, { name: 'Burger', price: 15.00 }] }.to_json }
      let(:service) { double('AddMenuItemToMenu') }
      let(:result) { menu.values.merge(menu_items: [{ name: 'Caesar Salad', price: 12.99 }, { name: 'Burger', price: 15.00 }]) }

      before do
        allow(service).to receive(:success).and_yield(result)
        allow(service).to receive(:failure)

        allow(AddMenuItemToMenu).to receive(:call).and_yield(service)
        post "/#{menu.id}/menu_items", data, { 'CONTENT_TYPE' => 'application/json' }
      end

      it 'returns a 201 status code' do
        expect(last_response.status).to eq(201)
      end
    end

    context 'with invalid menu items' do
      let(:data) { { menu_items: [{ name: '', price: nil }] }.to_json }
      let(:service) { double('AddMenuItemToMenu') }
      let(:errors) { { name: ['is not present'] } }

      before do
        allow(service).to receive(:success)
        allow(service).to receive(:failure).and_yield(errors)

        allow(AddMenuItemToMenu).to receive(:call).and_yield(service)
        post '/42/menu_items', data, { 'CONTENT_TYPE' => 'application/json' }
      end

      it 'returns a 422 status code' do
        expect(last_response.status).to eq(422)
      end
    end
  end
end
