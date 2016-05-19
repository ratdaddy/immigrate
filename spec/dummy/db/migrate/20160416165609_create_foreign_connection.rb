class CreateForeignConnection < ActiveRecord::Migration
  def change
    create_foreign_connection :foreign_server

    create_foreign_table :posts, :foreign_server do |t|
      t.string :title
    end

    create_table :comments do |t|
      t.string :author
    end
  end
end
