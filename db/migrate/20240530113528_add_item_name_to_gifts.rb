class AddItemNameToGifts < ActiveRecord::Migration[7.1]
  def change
    add_column :gifts, :item_name, :string
  end
end
