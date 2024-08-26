class AddDisplayChoiceToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :display_choice, :string
  end
end
