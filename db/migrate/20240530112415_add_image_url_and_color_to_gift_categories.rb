class AddImageUrlAndColorToGiftCategories < ActiveRecord::Migration[7.1]
  def change
    add_column :gift_categories, :image_url, :string
    add_column :gift_categories, :color, :string
  end
end
