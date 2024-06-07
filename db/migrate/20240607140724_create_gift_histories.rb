class CreateGiftHistories < ActiveRecord::Migration[7.1]
  def change
    create_table :gift_histories do |t|
      t.integer :gift_id
      t.text :sender_message

      t.timestamps
    end
  end
end
