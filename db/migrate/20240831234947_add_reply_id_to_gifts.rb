class AddReplyIdToGifts < ActiveRecord::Migration[6.1]
  def change
    add_column :gifts, :reply_id, :bigint
    add_index :gifts, :reply_id
  end
end
