class Gift < ApplicationRecord
  belongs_to :giver, class_name: 'User', optional: true
  belongs_to :receiver, class_name: 'User', optional: true
  belongs_to :gift_category
  belongs_to :gift_template, optional: true # optional: trueを追加
  has_many :gift_histories, dependent: :nullify
  belongs_to :reply, optional: true # optional: trueを指定することで、reply_idがnilでも保存できるようにする

  # コールバックを使用してメッセージの変更を保存
  after_update :store_sender_message_in_history, if: -> { saved_change_to_sender_message? }

  private

  # 送信者メッセージが更新された後に履歴を保存するメソッド
  def store_sender_message_in_history
    GiftHistory.create(gift_id: id, sender_message: sender_message_was)
  end
end