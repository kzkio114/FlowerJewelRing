class AddDisplayChoiceToReplies < ActiveRecord::Migration[7.1]
  def change
    add_column :replies, :display_choice, :string
  end
end
