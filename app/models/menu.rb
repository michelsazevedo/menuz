# frozen_string_literal: true

# Menu Model
class Menu < Sequel::Model
  include ApplicationModel
  include Searchable

  many_to_one  :restaurant
  many_to_many :menu_items

  searchable :name

  def validate
    super
    validates_presence %i[name restaurant_id]
    validates_length_range 1..155, :name
  end
end
