class AddAnonymousToReplies < ActiveRecord::Migration[7.1]
  def change
    add_column :replies, :anonymous, :boolean
  end
end
