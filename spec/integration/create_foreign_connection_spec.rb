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

      expect(connection).to be_extension_enabled(:postgres_fdw),
          'expected postgres_fdw extension to be enabled'
    end

    it 'is reverted by a rollback' do
      `RAILS_ENV=integration_test rake db:migrate 2>&1`
      output = `RAILS_ENV=integration_test rake db:rollback 2>&1`

      expect($?.exitstatus).to eq(0), "rake db:migrate was unsuccessful, output:\n#{output}"
      expect(connection).not_to be_extension_enabled(:postgres_fdw),
          'expected postgres_fdw extension to be disabled'
    end
  end

  it 'migrates from a generated model', :silence do
    create_connection_migration.migrate :up

    expect(connection).to be_extension_enabled(:postgres_fdw),
        'expected postgres_fdw extension to be enabled'
  end

  it 'reverts from a generated model', :silence do
    create_connection_migration.migrate :up
    create_connection_migration.migrate :down

    expect(connection).not_to be_extension_enabled(:postgres_fdw),
        'expected postgres_fdw extension to be disabled'
  end

  def create_connection_migration
    new_migration do
      def change
        create_foreign_connection :foreign_server
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

  def connection
    Class.new { extend Immigrate::SchemaStatements }.connection
  end

  def extension_check
    "SELECT extname FROM pg_catalog.pg_extension WHERE extname = 'postgres_fdw'"
  end
end
