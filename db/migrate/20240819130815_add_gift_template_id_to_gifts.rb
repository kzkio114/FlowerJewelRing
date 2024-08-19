class AddGiftTemplateIdToGifts < ActiveRecord::Migration[7.1]
  def change
    add_column :gifts, :gift_template_id, :integer
  end
end
