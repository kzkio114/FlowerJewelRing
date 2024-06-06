class AddReadToReplies < ActiveRecord::Migration[7.1]
  def change
    add_column :replies, :read, :boolean, default: false
  end
end
