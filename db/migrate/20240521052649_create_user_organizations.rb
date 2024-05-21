class CreateUserOrganizations < ActiveRecord::Migration[7.1]
  def change
    create_table :user_organizations do |t|
      t.integer :id
      t.integer :user_id
      t.integer :organization_id
      t.datetime :joined_at

      t.timestamps
    end
  end
end
