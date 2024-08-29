class AddDefaultAnonymousToUsers < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :anonymous, false
  end
end
