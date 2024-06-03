class ModifyGifts < ActiveRecord::Migration[7.1]
  def change
    rename_column :gifts, :message, :description
    add_column :gifts, :sender_message, :text
  end
end