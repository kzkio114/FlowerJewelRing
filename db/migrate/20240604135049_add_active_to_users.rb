class AddActiveToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :active, :boolean, default: true
  end
end
