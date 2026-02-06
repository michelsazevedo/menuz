# frozen_string_literal: true

# Restaurants
class RestaurantsController < ApplicationController
  get '/' do
    restaurants = Restaurant.all
    render json: { data: restaurants, error: nil }, status: 200
  end

  get '/:id' do
    restaurant = Restaurant[params[:id]]

    if restaurant
      render json: { data: restaurant, error: nil }, status: 200
    else
      render json: { data: nil, error: [:not_found] }, status: 404
    end
  end

  post '/' do
    CreateRestaurant.call(restaurant_params) do |service|
      service.success do |restaurant|
        render json: { data: restaurant, error: nil }, status: 201
      end

      service.failure do |errors|
        render json: { data: nil, errors: errors }, status: 422
      end
    end
  end

  private

  # @return [Hash]
  def restaurant_params
    request_params.slice(:name, :location)
  end
end