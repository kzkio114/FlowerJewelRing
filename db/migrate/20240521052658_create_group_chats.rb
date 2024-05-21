class CreateGroupChats < ActiveRecord::Migration[7.1]
  def change
    create_table :group_chats do |t|
      t.string :title

      t.timestamps
    end
  end
end
