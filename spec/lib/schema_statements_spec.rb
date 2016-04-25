require 'spec_helper'

module Immigrate
  describe SchemaStatements do
    let(:connection) { Class.new { extend SchemaStatements }}
    let(:database) { Immigrate.database }

    describe '#create_foreign_connection' do
      before :each do
        allow(database).to receive(:create_fdw_extension)
        allow(database).to receive(:create_server_connection)
      end

      it 'creates the fdw extension' do
        connection.create_foreign_connection :foreign_server

        expect(database).to have_received(:create_fdw_extension)
      end

      it 'creates the server connection' do
        connection.create_foreign_connection :foreign_server

        expect(database).to have_received(:create_server_connection).with(:foreign_server)
      end
    end

    describe 'drop_foreign_connection' do
      before :each do
        allow(database).to receive(:drop_fdw_extension)
      end

      it 'drops the fdw extension' do
        connection.drop_foreign_connection :foreign_server

        expect(database).to have_received(:drop_fdw_extension)
      end
    end
  end
end
