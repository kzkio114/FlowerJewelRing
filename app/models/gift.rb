class Gift < ApplicationRecord
  belongs_to :giver, class_name: 'User', optional: true
  belongs_to :receiver, class_name: 'User', optional: true
  belongs_to :gift_category
  belongs_to :gift_template, optional: true # optional: trueを追加
  has_many :gift_histories, dependent: :destroy

  # コールバックを使用してメッセージの変更を保存
  after_update :store_sender_message_in_history, if: -> { saved_change_to_sender_message? }

  private

  # 送信者メッセージが更新された後に履歴を保存するメソッド
  def store_sender_message_in_history
    GiftHistory.create(gift_id: id, sender_message: sender_message_was)
  end
end

class GiftTemplate < ApplicationRecord
  belongs_to :gift_category

  validates :name, presence: true
  validates :gift_category_id, presence: true
end

class GiftCategory < ApplicationRecord
  has_many :gifts, dependent: :destroy
  has_many :gift_templates, dependent: :destroy
end
