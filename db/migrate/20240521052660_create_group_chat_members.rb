class CreateGroupChatMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :group_chat_members do |t|
      t.integer :id
      t.integer :group_chat_id
      t.integer :user_id
      t.integer :role
      t.datetime :joined_at

      t.timestamps
    end
  end
end
