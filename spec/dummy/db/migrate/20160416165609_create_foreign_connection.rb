class CreateForeignConnection < ActiveRecord::Migration
  def change
    create_foreign_connection :foreign_server
  end
end
