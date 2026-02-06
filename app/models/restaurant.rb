# frozen_string_literal: true

# Restaurant Model
class Restaurant < Sequel::Model
  include ApplicationModel

  def validate
    super
    validates_presence %i[name location]
    validates_unique :name
    validates_length_range 4..155, :name
  end
end