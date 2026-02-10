# frozen_string_literal: true

source 'https://rubygems.org'

gem 'sinatra'

gem 'erb'
gem 'oj'
gem 'ostruct'
gem 'puma'
gem 'rack'
gem 'redis'
gem 'sequel'
gem 'sqlite3'

gem 'connection_pool'
gem 'sidekiq'

gem 'zeitwerk'

group :development, :test do
  gem 'awesome_print'
  gem 'debug', platforms: %i[mri windows]
  gem 'rubocop', require: false
end

group :test do
  gem 'factory_bot'
  gem 'ffaker'
  gem 'rack-test'
  gem 'rspec'
  gem 'simplecov'
end