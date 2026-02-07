# frozen_string_literal: true

# Restaurants
class RestaurantsController < ApplicationController
  get '/' do
    render json: as_json_collection(Restaurant.search(**search_params)), status: 200
  end

  get '/:id' do
    restaurant = Restaurant[params[:id]]

    if restaurant
      render json: as_json(restaurant), status: 200
    else
      render json: as_json(nil, errors: ["not found"]), status: 404
    end
  end

  post '/' do
    CreateRestaurant.call(restaurant_params) do |service|
      service.success do |restaurant|
        render json: as_json(restaurant), status: 201
      end

      service.failure do |errors|
        render json: as_json(nil, errors: errors), status: 422
      end
    end
  end

  private

  # @return [Hash]
  def restaurant_params
    req_params.slice(:name, :location)
  end

  # @return [Hash]
  def search_params
    q, page, per_page = params.values_at(:q, :page, :per_page)
    {q:, page:, per_page:}.compact
  end
end