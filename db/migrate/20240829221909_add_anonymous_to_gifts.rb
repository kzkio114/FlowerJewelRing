class AddAnonymousToGifts < ActiveRecord::Migration[7.1]
  def change
    add_column :gifts, :anonymous, :boolean
  end
end
