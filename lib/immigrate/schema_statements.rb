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

    def create_foreign_table foreign_table, foreign_server
      fdw = create_foreign_table_definition(foreign_table, foreign_server)

      yield fdw if block_given?

      database.execute fdw.sql
    end

    def create_foreign_table_definition foreign_table, foreign_server
      ForeignTableDefinition.new foreign_table, foreign_server
    end

    def drop_foreign_table foreign_table, _foreign_server = nil
      database.execute "DROP FOREIGN TABLE #{foreign_table}"
    end

  private
    def database
      Immigrate.database
    end
  end
end
