# frozen_string_literal: true

module Searchable
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    attr_reader :searchable_columns

    def searchable(*columns)
      @searchable_columns = columns.flatten
    end

    def search(q: nil, page: 1, per_page: 20)
			return dataset.paginate(Integer(page), Integer(per_page)) unless q

      conditions = searchable_columns.map { |param| Sequel.ilike(param, "%#{q}%") }
      dataset.where(Sequel.|(*conditions)).paginate(Integer(page), Integer(per_page))
    end
  end
end
