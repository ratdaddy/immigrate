module Immigrate
  class Database
    def create_fdw_extension
      enable_extension :postgres_fdw
    end

    def drop_fdw_extension
      disable_extension :postgres_fdw
    end

    def create_server_connection server
      server_config = database_configuration[Rails.env][server.to_s]
      execute <<-SQL
        CREATE SERVER #{server}
        FOREIGN DATA WRAPPER postgres_fdw
        OPTIONS (host '#{server_config['host']}',
                 port '#{server_config['port']}',
                 dbname '#{server_config['dbname']}')
      SQL
    end

    def create_user_mapping server
      server_config = database_configuration[Rails.env][server.to_s]
      execute <<-SQL
        CREATE USER MAPPING FOR #{current_user}
        SERVER #{server}
        OPTIONS (user '#{server_config['user']}',
                 password '#{server_config['password']}')
      SQL
    end

    def current_user
      execute("SELECT CURRENT_USER").first['current_user']
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
