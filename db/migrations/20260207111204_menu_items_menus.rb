# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:menu_items_menus) do
      foreign_key :menu_id,      :menus,      null: false, on_delete: :cascade
      foreign_key :menu_item_id, :menu_items, null: false, on_delete: :cascade

      primary_key [:menu_id, :menu_item_id]
    end
  end
end
