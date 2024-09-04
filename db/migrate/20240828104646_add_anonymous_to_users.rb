class AddAnonymousToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :anonymous, :boolean
  end
end
