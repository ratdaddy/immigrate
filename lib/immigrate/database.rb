module Immigrate
  class Database
    def create_fdw_extension
      enable_extension :postgres_fdw
    end

    def drop_fdw_extension
      disable_extension :postgres_fdw
    end

    def create_server_connection server
      db_config = db_config(server)
      db, host, port, fetch_size = db_config.slice('database', 'host', 'port', 'fetch_size').values
      fetch_size ||= 50

      execute <<-SQL
        CREATE SERVER #{server}
        FOREIGN DATA WRAPPER postgres_fdw
        OPTIONS (
          dbname '#{db}',
          host '#{host}',
          port '#{port}',          
          fetch_size '#{fetch_size}'
        )
      SQL
    end

    def create_user_mapping server
      db_config = db_config(server)
      user, password = db_config.slice('user', 'password').values
      # stmnt = <<-SQL
      #   CREATE USER MAPPING FOR #{user}
      #   SERVER #{server}
      #   OPTIONS (
      #     user '#{user}',
      #     password '#{password}'
      #   )
      # SQL
      # execute(stmnt) if user != current_user
      stmnt = <<-SQL
        CREATE USER MAPPING FOR #{current_user}
        SERVER #{server}
        OPTIONS (
          user '#{user}',
          password '#{password}'
        )
      SQL
      execute stmnt
    end

    def db_config(server)
      return @db_config if defined?(@db_config)

      config = database_configuration[Rails.env][server.to_s]
      # if config['url'].present? - try refine db connection
      @db_config = ActiveRecord::DatabaseConfigurations::UrlConfig.new(Rails.env, server, config['url'], config).config
    end

    def current_user
      execute("SELECT CURRENT_USER").first['current_user']
    end

    delegate :execute, :enable_extension, :disable_extension, :type_to_sql, to: :connection

    def connection
      ActiveRecord::Base.connection
    end

    def database_configuration
      yaml = Pathname.new('config/immigrate.yml')
      YAML.load(ERB.new(yaml.read).result)
    end
  end
end
