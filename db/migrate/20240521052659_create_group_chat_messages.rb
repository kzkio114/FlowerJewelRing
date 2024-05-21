class CreateGroupChatMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :group_chat_messages do |t|
      t.references :group_chat, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :message

      t.timestamps
    end
  end
end
