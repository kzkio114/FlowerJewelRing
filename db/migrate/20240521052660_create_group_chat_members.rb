class CreateGroupChatMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :group_chat_members do |t|
      t.references :group_chat, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role
      t.datetime :joined_at

      t.timestamps
    end
  end
end