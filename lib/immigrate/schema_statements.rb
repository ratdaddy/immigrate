module Immigrate
  module SchemaStatements
    def create_foreign_connection foreign_server
      enable_extension :postgres_fdw
    end

    def drop_foreign_connection foreign_server
      disable_extension :postgres_fdw
    end

    delegate :enable_extension, :disable_extension, to: :connection

    def connection
      ActiveRecord::Base.connection
    end
  end
end
