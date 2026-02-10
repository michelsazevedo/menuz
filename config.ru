# warn_indent: true
# frozen_string_literal: true

require_relative './config/boot'
require 'sidekiq/web'

run Rack::URLMap.new(
  '/healthz' => HealthzController,
  '/restaurants' => RestaurantsController,
  '/menus' => MenusController,
  '/imports' => ImportsController,
  '/sidekiq' => Sidekiq::Web,
)
