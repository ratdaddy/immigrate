require 'spec_helper'

module Immigrate
  describe ForeignTableDefinition do
    subject { ForeignTableDefinition.new(:foreign_table, :foreign_server) }

    describe '#string' do
      it 'adds a name to the columns list' do
        subject.string(:foreign_column)

        expect(subject.columns).to eq([[:foreign_column, :string]])
      end
    end

    describe '#sql' do
      it 'returns sql sufficient to create the foreign table' do
        aggregate_failures do
          expect(subject.sql).to include('CREATE FOREIGN TABLE foreign_table')
          expect(subject.sql).to include('SERVER foreign_server')
        end
      end
    end
  end
end
