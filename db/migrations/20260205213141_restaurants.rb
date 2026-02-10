# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:restaurants) do
      primary_key :id

      String   :name,       null: false, size: 155
      String   :location,   text: true
      DateTime :created_at, null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end