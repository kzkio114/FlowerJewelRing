class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.references :organization, foreign_key: true, null: true
      t.string :email, null: false
      t.string :password_digest
      t.string :social_id
      t.string :display_name

      t.timestamps
    end

    add_index :users, :email, unique: true
  end
end