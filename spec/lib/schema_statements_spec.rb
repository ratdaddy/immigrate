require 'spec_helper'
require 'immigrate/schema_statements'

module Immigrate
  describe SchemaStatements do
    let(:connection) { Class.new { extend SchemaStatements }}
    let(:database) { Immigrate.database }

    describe '#create_foreign_connection' do
      before :each do
        allow(database).to receive(:create_fdw_extension)
        allow(database).to receive(:create_server_connection)
        allow(database).to receive(:create_user_mapping)
      end

      it 'creates the fdw extension' do
        connection.create_foreign_connection :foreign_server

        expect(database).to have_received(:create_fdw_extension)
      end

      it 'creates the server connection' do
        connection.create_foreign_connection :foreign_server

        expect(database).to have_received(:create_server_connection).with(:foreign_server)
      end

      it 'creates a user mapping' do
        connection.create_foreign_connection :foreign_server

        expect(database).to have_received(:create_user_mapping).with(:foreign_server)
      end
    end

    describe '#drop_foreign_connection' do
      before :each do
        allow(database).to receive(:drop_fdw_extension)
      end

      it 'drops the fdw extension' do
        connection.drop_foreign_connection :foreign_server

        expect(database).to have_received(:drop_fdw_extension)
      end
    end

    describe '#create_foreign_table' do
      let(:foreign_table_def) { instance_double('ForeignTableDefinition') }

      before :each do
        allow(connection).to receive(:create_foreign_table_definition).and_return(foreign_table_def)
        allow(database).to receive(:execute)
        allow(foreign_table_def).to receive(:sql).and_return('test sql statement')
      end

      it 'gets a table definition object with the given table name' do
        connection.create_foreign_table :foreign_table, :foreign_server, 'test_table_name'

        expect(connection).to have_received(:create_foreign_table_definition).with(:foreign_table, :foreign_server, 'test_table_name')
      end

      it 'yields the foreign_table_definition object to the given block' do
        expect { |b| connection.create_foreign_table(:foreign_table, :foreign_server, &b) }.to yield_with_args(foreign_table_def)
      end

      it 'executes the sql representing the foreign_table_definition' do

        connection.create_foreign_table :foreign_table, :foreign_server

        expect(database).to have_received(:execute).with('test sql statement')
      end
    end

    describe '#create_foreign_table_definition' do
      it 'returns a ForeignTableDefinition object' do
        foreign_table_definition = connection.create_foreign_table_definition(:foreign_table, :foreign_server, 'test_table_name')
        expect(foreign_table_definition).to be_a(ForeignTableDefinition)
        expect(foreign_table_definition.name).to be(:foreign_table)
        expect(foreign_table_definition.server).to be(:foreign_server)
        expect(foreign_table_definition.database).to be_a(Immigrate::Database)
        expect(foreign_table_definition.options).to eq({ remote_table_name: 'test_table_name', schema_name: 'public'})
      end
    end

    describe '#drop_foreign_table' do
      before :each do
        allow(database).to receive(:execute)
      end

      it 'drops the foreign table' do
        connection.drop_foreign_table :foreign_table

        expect(database).to have_received(:execute).with(include('DROP FOREIGN TABLE foreign_table'))
      end
    end
  end
end
