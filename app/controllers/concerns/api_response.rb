module ApiResponse
	def as_json(data, errors: nil)
		{ data: data, errors: errors }
	end

  def as_json_collection(dataset)
    {
      data: dataset.all,
        meta: {
          current_page: dataset.current_page,
        	page_count: dataset.page_count,
					page_size: dataset.page_size,
					total_count: dataset.pagination_record_count
        }
    }
  end
end