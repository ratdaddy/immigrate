module Immigrate
  module SchemaStatements
    def create_foreign_connection foreign_server
      execute 'CREATE EXTENSION postgres_fdw'
    end

    def drop_foreign_connection foreign_server
      execute 'DROP EXTENSION postgres_fdw'
    end

    delegate :execute, to: :connection

    def connection
      @@connection ||= ActiveRecord::Base.connection
    end
  end
end
