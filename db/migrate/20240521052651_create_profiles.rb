class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.integer :id
      t.integer :user_id
      t.text :introduction
      t.text :interests
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
