require 'spec_helper'

describe 'Foreign connection' do
  describe 'with rake migrations' do
    class Base < ActiveRecord::Base; end

    around :example do |example|
      ActiveRecord::Tasks::DatabaseTasks.create Rails.configuration.database_configuration['integration_test']
      Base.establish_connection :integration_test
      Dir.chdir(dummy_root) do
        example.run
      end
      Base.remove_connection
      ActiveRecord::Tasks::DatabaseTasks.drop Rails.configuration.database_configuration['integration_test']
    end

    let(:connection) { Base.connection }

    it 'is created by a migration' do
      output = `RAILS_ENV=integration_test rake db:migrate 2>&1`
      expect($?.exitstatus).to eq(0), "rake db:migrate was unsuccessful, output:\n#{output}"

      expect(connection).to be_extension_enabled(:postgres_fdw), 'expected postgres_fdw extension to be enabled'
      expect(foreign_table(:posts).count).to eq(1)
      expect(foreign_schema(:posts).first).to include('column_name' => 'title', 'data_type' => 'character varying')
    end

    it 'is reverted by a rollback' do
      `RAILS_ENV=integration_test rake db:migrate 2>&1`
      output = `RAILS_ENV=integration_test rake db:rollback 2>&1`

      expect($?.exitstatus).to eq(0), "rake db:migrate was unsuccessful, output:\n#{output}"
      expect(foreign_table(:posts).count).to eq(0)
      expect(connection).not_to be_extension_enabled(:postgres_fdw), 'expected postgres_fdw extension to be disabled'
    end
  end

  describe 'generated migration' do
    around :example do |example|
      Dir.chdir(dummy_root) do
        example.run
      end
    end

    let(:connection) { ActiveRecord::Base.connection }

    context 'create connection' do
      it 'migrates from a generated model', :silence do
        create_connection_migration.migrate :up

        expect(connection).to be_extension_enabled(:postgres_fdw), 'expected postgres_fdw extension to be enabled'
        expect(foreign_server.first['srvoptions']).to eq('{host=localhost,port=5432,dbname=foreign_db}')
        expect(user_mapping.first['umoptions']).to eq("{user=foreign_user,password=password}")
        expect(foreign_server.count).to eq(1)
      end

      it 'reverts from a generated model', :silence do
        create_connection_migration.migrate :up
        create_connection_migration.migrate :down

        aggregate_failures do
          expect(foreign_server.count).to eq(0)
          expect(connection).not_to be_extension_enabled(:postgres_fdw), 'expected postgres_fdw extension to be disabled'
        end
      end

      def create_connection_migration
        new_migration do
          def change
            create_foreign_connection :foreign_server
          end
        end
      end
    end

    context 'create table' do
      it 'migrates from a generated model', :silence do
        connection.create_foreign_connection :foreign_server
        create_table_migration.migrate :up

        expect(foreign_table(:foreign_table).count).to eq(1)
        expect(foreign_schema(:foreign_table).first).to include('column_name' => 'some_string', 'data_type' => 'character varying')
      end

      it 'reverts from a generated model', :silence do
        connection.create_foreign_connection :foreign_server
        create_table_migration.migrate :up
        create_table_migration.migrate :down

        expect(foreign_table(:foreign_table).count).to eq(0)
      end

      def create_table_migration
        new_migration do
          def change
            create_foreign_table :foreign_table, :foreign_server do |t|
              t.string :some_string
            end
          end
        end
      end
    end

    def new_migration &block
      if ActiveRecord::Migration.respond_to? :'[]'
        Class.new(ActiveRecord::Migration[4.2], &block)
      else
        Class.new(ActiveRecord::Migration, &block)
      end
    end

    def foreign_server
      connection.execute("SELECT * FROM pg_foreign_server WHERE srvname = 'foreign_server'")
    end

    def user_mapping
      connection.execute <<-SQL
        SELECT *
        FROM pg_user_mappings
        WHERE srvname = 'foreign_server' AND usename = '#{current_user}'
      SQL
    end

    def current_user
      connection.execute("SELECT CURRENT_USER").first['current_user']
    end
  end

  def foreign_table name
    connection.execute("SELECT * FROM information_schema.tables WHERE table_name='#{name}'")
  end

  def foreign_schema name
    connection.execute("SELECT * FROM information_schema.columns WHERE table_name='#{name}'")
  end
end
