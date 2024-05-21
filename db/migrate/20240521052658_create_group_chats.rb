class CreateGroupChats < ActiveRecord::Migration[7.1]
  def change
    create_table :group_chats do |t|
      t.integer :id
      t.string :title
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
