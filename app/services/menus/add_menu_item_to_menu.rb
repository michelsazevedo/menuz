# frozen_string_literal: true

# Add MenuItems to Menu
class AddMenuItemToMenu
  include Result

  attributes :menu_id, :menu_items

  def call
    menu = Menu[menu_id]
    return Failure(menu: ['not found']) unless menu

    items = menu_items.map { |attrs| MenuItem.new(attrs) }

    if items.all?(&:valid?)
      Menu.db.transaction do
        menu_item_ids = upsert_menu_items!(items)
        attach_menu_items!(menu_id, menu_item_ids)
      end
      
      Success(menu.reload.values.merge(menu_items: menu.menu_items.map(&:values)))
    else
      errors = items.reject(&:valid?).map.with_index { |item, i| { index: i, errors: item.errors } }
      Failure(errors)
    end
  end

  private

  # Upserts menu items and returns their IDs
  def upsert_menu_items!(menu_items)
    MenuItem
      .dataset
      .insert_conflict(
        target: %i[name],
        update: { price: Sequel[:excluded][:price] }
      )
      .multi_insert(menu_items)

    MenuItem.where(name: menu_items.map { |item| item[:name] }).select_map(:id)
  end

  def attach_menu_items!(menu_id, menu_items)
    menu_menu_items = menu_items.map { |item_id| { menu_id: menu_id, menu_item_id: item_id } }
    
    Menu.db[:menu_items_menus]
      .insert_conflict(target: %i[menu_id menu_item_id])
      .multi_insert(menu_menu_items)
  end
end
