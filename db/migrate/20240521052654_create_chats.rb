class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.integer :id
      t.integer :sender_id
      t.integer :receiver_id
      t.text :message
      t.text :encrypted
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
