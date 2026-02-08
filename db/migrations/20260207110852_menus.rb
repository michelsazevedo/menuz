# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:menus) do
      primary_key :id

      foreign_key :restaurant_id, :restaurants, null: false, on_delete: :cascade

      String   :name,        null: false, size: 155
      String   :description, text: true
      DateTime :created_at,  null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at,  null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
