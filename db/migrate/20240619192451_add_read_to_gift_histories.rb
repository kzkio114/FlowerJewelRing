class AddReadToGiftHistories < ActiveRecord::Migration[7.1]
  def change
    add_column :gift_histories, :read, :boolean, default: false
    add_index :gift_histories, :read
  end
end
