class Gift < ApplicationRecord
  belongs_to :giver, class_name: 'User', optional: true  # optional: trueを追加
  belongs_to :receiver, class_name: 'User', optional: true  # optional: trueを追加
  belongs_to :gift_category
  has_many :gift_histories, dependent: :destroy


  # コールバックを使用してメッセージの変更を保存
  after_update :save_to_history, if: -> { saved_change_to_sender_message? }

  private

  # 送信者メッセージが更新された後に履歴を保存するメソッド
  def save_to_history
    GiftHistory.create(gift_id: id, sender_message: sender_message_was)
  end
end