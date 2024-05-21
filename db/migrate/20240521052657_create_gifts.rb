class CreateGifts < ActiveRecord::Migration[7.1]
  def change
    create_table :gifts do |t|
      t.references :giver, null: false, foreign_key: { to_table: :users }
      t.references :receiver, null: false, foreign_key: { to_table: :users }
      t.references :gift_category, null: false, foreign_key: true
      t.text :message
      t.datetime :sent_at

      t.timestamps
    end
  end
end