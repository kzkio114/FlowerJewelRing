class CreateGiftTemplates < ActiveRecord::Migration[7.1]
  def change
    create_table :gift_templates do |t|
      t.string :name
      t.text :description
      t.string :image_url
      t.string :color

      t.timestamps
    end
  end
end
