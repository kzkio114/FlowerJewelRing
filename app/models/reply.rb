class Reply < ApplicationRecord
  belongs_to :consultation
  belongs_to :user

  validates :content, presence: { message: "を入力してください" }, format: { with: /\A(?!\p{Space}*\z).*\S/, message: "は空白文字だけで投稿できません" }, length: { maximum: 5000 }
end