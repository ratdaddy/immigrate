require 'spec_helper'

module Immigrate
  describe SchemaStatements do
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
