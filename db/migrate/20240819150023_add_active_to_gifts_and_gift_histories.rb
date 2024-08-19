class AddActiveToGiftsAndGiftHistories < ActiveRecord::Migration[7.1]
  def change
    add_column :gifts, :active, :boolean, default: true, null: false
    add_column :gift_histories, :active, :boolean, default: true, null: false
  end
end
