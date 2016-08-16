class CreateForeignConnection < ActiveRecord::Migration
  def change
    create_foreign_connection :foreign_server

    create_foreign_table :posts, :foreign_server do |t|
      t.string :title
      t.column :author, :string
      t.string :mistake
    end

    change_foreign_table :posts, :foreign_server do |t|
      t.remove :mistake
    end

    change_table :posts do |t|
      puts t.method(:remove).source_location
    end
  end
end
