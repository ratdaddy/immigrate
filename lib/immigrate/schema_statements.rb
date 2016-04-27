module Immigrate
  module SchemaStatements
    def create_foreign_connection foreign_server
      database.create_fdw_extension
      database.create_server_connection foreign_server
      database.create_user_mapping foreign_server
    end

    def drop_foreign_connection _foreign_server
      database.drop_fdw_extension
    end

  private
    def database
      Immigrate.database
    end
  end
end
