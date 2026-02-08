# frozen_string_literal: true

# Menus
class MenusController < ApplicationController
  get '/:id' do
    menu = Menu[params[:id]]

    if menu
      render json: as_json(menu.values.merge(menu_items: menu.menu_items.map(&:values))), status: 200
    else
      render json: as_json(nil, errors: ['not found']), status: 404
    end
  end

  post '/' do
    CreateMenu.call(menu_params) do |service|
      service.success do |menu|
        render json: as_json(menu), status: 201
      end

      service.failure do |errors|
        render json: as_json(nil, errors: errors), status: 422
      end
    end
  end

  post '/:id/menu_items' do
    AddMenuItemToMenu.call(add_item_params) do |service|
      service.success do |menu|
        render json: as_json(menu), status: 201
      end

      service.failure do |errors|
        render json: as_json(nil, errors: errors), status: 422
      end
    end
  end

  private

  def menu_params
    req_params.slice(:name, :description, :restaurant_id)
  end

  def add_item_params
    { 
      menu_id: params[:id].to_i, 
      menu_items: Array(req_params[:menu_items]).map { |item| item.slice(:name, :price) }
    }
  end
end
