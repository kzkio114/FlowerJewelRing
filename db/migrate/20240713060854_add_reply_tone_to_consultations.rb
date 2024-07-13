class AddReplyToneToConsultations < ActiveRecord::Migration[7.1]
  def change
    add_column :consultations, :desired_reply_tone, :string
  end
end
