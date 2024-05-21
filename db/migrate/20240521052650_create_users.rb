class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.integer :id
      t.string :name
      t.integer :organization_id
      t.string :email
      t.string :password_digest
      t.string :social_id
      t.string :display_name
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
