# frozen_string_literal: true

# Import Model
class Import < Sequel::Model
  include ApplicationModel
  include Searchable

  STATUSES = %w[pending processing processed failed].freeze

  STATUSES.each do |status_name|
    define_method("#{status_name}!") do |**attrs|
      update({ status: status_name }.merge(attrs))
    end
  end

  def validate
    super
    validates_presence %i[file_location status]
    validates_includes STATUSES, :status
  end
end
