# frozen_string_literal: true

# Application Base
class ApplicationController < Sinatra::Base
  use LogzMiddleware

  configure :production, :development do
    set :bind, '0.0.0.0'
    set :port, 3000
    set :logger, Sinatra.logger
  end

  helpers ApiResponse

  helpers do
    def req_params
      body = Oj.load(request.body.read)
      symbolize_keys!(body)
    rescue Oj::ParseError
      render json: Oj.dump({ data: nil, errors: 'Invalid JSON format' }), status: 400
    end

    def render(json:, status: 200)
      content_type :json
      halt status, Oj.dump(json)
    end

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
end