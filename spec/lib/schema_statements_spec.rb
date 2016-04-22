require 'spec_helper'
require 'immigrate/schema_statements'

module Immigrate
  describe SchemaStatements do
    subject { Class.new { extend SchemaStatements }.connection }

    before :each do
      allow(subject).to receive(:database_configuration).and_return(
          'test' => {
            'some_foreign_server' => {
              'host' => 'some_foreign_host',
              'port' => 'some_foreign_port',
              'dbname' => 'some_foreign_db'
          }})
    end

    describe '#create_foreign_connection' do
      it 'creates the fdw extension' do
        connection.create_foreign_connection :foreign_server

        expect(connection).to be_extension_enabled(:postgres_fdw),
            'expected postgres_fdw extension to be enabled'
      end
    end

    describe '#drop_foreign_connection' do
      it 'drops the fdw extension' do
        connection.create_foreign_connection :foreign_server
        connection.drop_foreign_connection :foreign_server

        expect(connection).not_to be_extension_enabled(:postgres_fdw),
            'expected postgres_fdw extension to be disabled'
      end
    end

    def connection
      Class.new { extend SchemaStatements }.connection
    end
  end
end
