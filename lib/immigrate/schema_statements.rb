module Immigrate
  module SchemaStatements
    def create_foreign_connection foreign_server
      # database.create_fdw_extension
      database.create_server_connection foreign_server
      database.create_user_mapping foreign_server
    end

    def drop_foreign_connection _foreign_server
      database.drop_fdw_extension
    end

    def create_foreign_table foreign_table, foreign_server, remote_table_name = foreign_table
      fdw = create_foreign_table_definition(foreign_table, foreign_server, remote_table_name)

      yield fdw if block_given?

      database.execute fdw.sql
    end

    def create_foreign_table_definition foreign_table, foreign_server, remote_table_name
      ForeignTableDefinition.new foreign_table, foreign_server, remote_table_name: remote_table_name
    end

    def drop_foreign_table foreign_table, _foreign_server = nil, _remote_table_name = nil
      database.execute "DROP FOREIGN TABLE #{foreign_table}"
    end

  private
    def database
      Immigrate.database
    end
  end
end
