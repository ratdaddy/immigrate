module Immigrate
  module SchemaStatements
    def create_foreign_connection _foreign_server
      enable_extension :postgres_fdw

      db_config = database_configuration[Rails.env]
      server = db_config.keys.first
      server_config = db_config[server]
      execute <<-SQL
        CREATE SERVER #{server}
        FOREIGN DATA WRAPPER postgres_fdw
        OPTIONS (host '#{server_config['host']}',
                 port '#{server_config['port']}',
                 dbname '#{server_config['dbname']}')
      SQL
    end

    def drop_foreign_connection _foreign_server
      disable_extension :postgres_fdw
    end

    delegate :execute, :enable_extension, :disable_extension, to: :connection

    def connection
      ActiveRecord::Base.connection
    end

    def database_configuration
      yaml = Pathname.new('config/immigrate.yml')
      YAML.load(ERB.new(yaml.read).result)
    end
  end
end
