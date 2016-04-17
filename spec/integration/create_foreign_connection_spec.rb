require 'spec_helper'
require 'active_record'

describe 'Foreign connection' do
  around :example do |example|
    Dir.chdir(dummy_root) do
      example.run
      ActiveRecord::SchemaMigration.drop_table
    end
  end

  it 'is created by a migration' do
    output = `RAILS_ENV=test rake db:migrate 2>&1`
    expect($?.exitstatus).to eq(0), "rake db:migrate was unsuccessful, output:\n#{output}"
  end
end
