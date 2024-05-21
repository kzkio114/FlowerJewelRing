class CreateAdminUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :admin_users do |t|
      t.integer :id
      t.integer :user_id
      t.integer :organization_id
      t.integer :admin_role
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
