# frozen_string_literal: true

# Imports
class ImportsController < ApplicationController
  get '/' do
    render json: as_json_collection(Import.search(**search_params)), status: 200
  end

  get '/:id' do
    import = Import[params[:id]]

    if import
      render json: as_json(import), status: 200
    else
      render json: as_json(nil, errors: ['not found']), status: 404
    end
  end

  # @return [Hash]
  def search_params
    q, page, per_page = params.values_at(:q, :page, :per_page)
    {q:, page:, per_page:}.compact
  end
end
