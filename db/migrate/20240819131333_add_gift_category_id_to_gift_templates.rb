class AddGiftCategoryIdToGiftTemplates < ActiveRecord::Migration[7.1]
  def change
    add_column :gift_templates, :gift_category_id, :bigint
  end
end
