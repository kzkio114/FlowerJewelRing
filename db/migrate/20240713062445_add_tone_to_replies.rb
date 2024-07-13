class AddToneToReplies < ActiveRecord::Migration[7.1]
  def change
    add_column :replies, :tone, :string
  end
end
