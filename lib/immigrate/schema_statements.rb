module Immigrate
  module SchemaStatements
    def create_foreign_connection foreign_server
      ActiveRecord::Base.connection.execute 'CREATE EXTENSION postgres_fdw'
    end

    def drop_foreign_connection foreign_server
      ActiveRecord::Base.connection.execute 'DROP EXTENSION postgres_fdw'
    end
  end
end
