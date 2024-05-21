class CreateReplies < ActiveRecord::Migration[7.1]
  def change
    create_table :replies do |t|
      t.integer :id
      t.integer :consultation_id
      t.integer :user_id
      t.text :content
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
