# frozen_string_literal: true

# Sidekiq worker for async restaurant imports
class ImportRestaurantsWorker
  include Sidekiq::Job

  sidekiq_options queue: 'default', retry: 3

  def perform(import_id)
    import = Import[import_id]
    return unless import

    import.processing!

    file_content = File.read(import.file_location)
    data = Oj.load(file_content, symbol_keys: true)

    restaurants = symbolize_keys!(data[:restaurants] || [])
    result = ImportRestaurants.call(restaurants: restaurants)

    import.processed!(total_records: result.length)
  rescue Oj::ParseError, EncodingError => e
    import&.failed!(error_message: "JSON parse error: #{e.message}")
  rescue StandardError => e
    import&.failed!(error_message: e.message)
    raise
  end

  private

  def symbolize_keys!(object)
    if object.is_a?(Array)
      object.each_with_index do |val, index|
        object[index] = symbolize_keys!(val)
      end
    elsif object.is_a?(Hash)
      object.keys.each do |key|
        object[key.to_sym] = symbolize_keys!(object.delete(key))
      end
    end
    object
  end
end
