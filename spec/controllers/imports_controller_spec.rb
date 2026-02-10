# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ImportsController, type: :controller do
  describe 'GET /' do
    it 'returns http success' do
      get '/'
      expect(last_response.status).to eq(200)
    end

    it 'returns a paginated list of imports' do
      Import.create(status: 'pending', file_location: '/tmp/test1.json')
      Import.create(status: 'processed', file_location: '/tmp/test2.json')

      get '/'
      body = Oj.load(last_response.body)

      expect(body['data'].length).to eq(2)
      expect(body['meta']).to include('current_page', 'page_count', 'page_size', 'total_count')
    end
  end

  describe 'GET /:id' do
    it 'returns the import when found' do
      import = Import.create(status: 'pending', file_location: '/tmp/test.json')

      get "/#{import.id}"
      body = Oj.load(last_response.body)

      expect(last_response.status).to eq(200)
      expect(body['data']['status']).to eq('pending')
    end

    it 'returns 404 when not found' do
      get '/42'

      expect(last_response.status).to eq(404)
    end
  end
end
