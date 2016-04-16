class CreateForeignConnection < ActiveRecord::Migration[5.0]
  def change
    create_foreign_connection :foreign_server
  end
end
