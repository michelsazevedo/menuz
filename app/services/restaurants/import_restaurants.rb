# frozen_string_literal: true

# Import Restaurants with Menus and MenuItems
class ImportRestaurants
  attr_reader :restaurants

  def self.call(restaurants:)
    ImportRestaurants.new(restaurants:).call
  end

  def initialize(restaurants:)
    @restaurants = restaurants
  end

  def call
    restaurants.map(&method(:import!))
  end

  private

  def import!(data)
    Menu.db.transaction do
      service = CreateRestaurant.call(name: data[:name])
      return unless service.success?
      
      Array(data[:menus]).each { |menu_data| import_menu!(service.value, menu_data) }
    end
  end

  def import_menu!(restaurant, menu_data)
    service = CreateMenu.call(name: menu_data[:name], restaurant_id: restaurant[:id])
    return unless service.success?

    menu = service.value
    items = (menu_data[:menu_items] || menu_data[:dishes] || [])
              .uniq { |item| item[:name] }
              .map { |item| item.slice(:name, :price) }

    AddMenuItemToMenu.call(menu_id: menu[:id], menu_items: items) unless items.empty?
  end
end
