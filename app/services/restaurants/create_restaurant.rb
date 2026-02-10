# frozen_string_literal: true

# Create Restaurant
class CreateRestaurant
  include Result

  attributes :name, :location

  def call
    restaurant = Restaurant.first(name:)
    return Success(restaurant.values) if restaurant

    restaurant = Restaurant.new({ name:, location: }.compact)

    if restaurant.valid?
      restaurant.save!

      Success(restaurant.values)
    else
      Failure(restaurant.errors)
    end
  end
end