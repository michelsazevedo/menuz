# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:imports) do
      primary_key :id

      String   :status,            null: false, default: 'pending', size: 20
      String   :file_location,     null: false, text: true
      String   :error_message,     text: true
      Integer  :total_records
      Integer  :processed_records
      DateTime :created_at,        null: false, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at,        null: false, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
