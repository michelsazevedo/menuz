# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:menu_items) do
      primary_key :id

      String     :name,        null: false, size: 155, unique: true
      String     :description, text: true
      BigDecimal :price,       null: false, size: [10, 2]
      DateTime   :created_at,  null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime   :updated_at,  null: false, default: Sequel::CURRENT_TIMESTAMP
    end

    add_index :menu_items, :name, unique: true
  end
end
