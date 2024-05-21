class CreateGifts < ActiveRecord::Migration[7.1]
  def change
    create_table :gifts do |t|
      t.integer :id
      t.integer :giver_id
      t.integer :receiver_id
      t.integer :gift_category_id
      t.text :message
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :sent_at

      t.timestamps
    end
  end
end
