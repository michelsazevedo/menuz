# frozen_string_literal: true

require 'sequel'
require 'logger'

## A Sequel-backed thread-safe DB wrapper with connection pooling
class SequelDb
  class << self
    attr_reader :instance

    ## Configures and initializes the global DB instance
    #
    # @param database_url [String] database connection string
    # @param pool_size [Integer] max connections in the pool
    # @param logger [Logger] logger instance
    #
    # @return [SequelDb]
    def configure(database_url: ENV['DATABASE_URL'], pool_size: ENV.fetch('SEQUEL_POOL', 5), logger: nil)
      @database_url = database_url || 'sqlite://db/menuz.sqlite3'
      @pool_size    = pool_size
      @logger       = logger || Logger.new($stdout)

      @instance = new(database_url: @database_url, pool_size: @pool_size, logger: @logger)
    end
  end

  def initialize(database_url:, pool_size:, logger:)
    @logger = logger

    @db = Sequel.connect(database_url, max_connections: ENV.fetch('SEQUEL_POOL', 5)).tap do |db|
      db.run('PRAGMA journal_mode=WAL;')
      db.extension :pagination
    end

    graceful_shutdown
  end

  ## Executes a block using the Sequel connection
  #
  # @yieldparam db [Sequel::Database]
  def with_db
    yield db
  rescue Sequel::DatabaseError => e
    logger.error("Database error: #{e.message}")
    raise
  end

  ## Shortcut to access the raw Sequel::Database
  attr_reader :db

  private

  attr_reader :logger

  def graceful_shutdown
    at_exit do
      db.disconnect
    end
  end

  configure
end
