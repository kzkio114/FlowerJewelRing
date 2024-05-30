class AddImageUrlAndColorToGifts < ActiveRecord::Migration[7.1]
  def change
    add_column :gifts, :image_url, :string
    add_column :gifts, :color, :string
  end
end
