class ChangeColumnNullForGifts < ActiveRecord::Migration[7.1]
  def change
    change_column_null :gifts, :giver_id, true
    change_column_null :gifts, :receiver_id, true
  end
end
