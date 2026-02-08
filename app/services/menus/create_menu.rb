# frozen_string_literal: true

# Create Menu
class CreateMenu
  include Result

  attributes :name, :description, :restaurant_id

  def call
    menu = Menu.new(name:, description:, restaurant_id:)

    if menu.valid?
      menu.save!

      Success(menu.values)
    else
      Failure(menu.errors)
    end
  end
end
