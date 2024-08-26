class RemoveDisplayChoiceFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :display_choice, :string
  end
end
