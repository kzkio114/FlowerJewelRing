class AddSentCountToReplies < ActiveRecord::Migration[7.1]
  def change
    add_column :replies, :sent_count, :integer, default: 0
  end
end
