# frozen_string_literal: true

# MenuItem Model
class MenuItem < Sequel::Model
  include ApplicationModel
  include Searchable

  many_to_many :menus

  searchable :name

  attr_accessor :skip_uniqueness

  def validate
    super
    validates_presence %i[name price]
    validates_length_range 1..155, :name
  end
end
