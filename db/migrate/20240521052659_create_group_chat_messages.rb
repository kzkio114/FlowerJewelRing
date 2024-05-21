class CreateGroupChatMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :group_chat_messages do |t|
      t.integer :id
      t.integer :group_chat_id
      t.integer :user_id
      t.text :message
      t.datetime :created_at

      t.timestamps
    end
  end
end
