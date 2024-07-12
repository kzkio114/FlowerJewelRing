class Consultation < ApplicationRecord
  searchkick
  
  belongs_to :user
  belongs_to :category
  has_many :replies, dependent: :destroy

  validates :title, presence: { message: "を入力してください" }, format: { with: /\A(?!\p{Space}*\z).*\S/, message: "は空白文字だけで投稿できません" }, length: { maximum: 50 }
  validates :content, presence: { message: "を入力してください" }, format: { with: /\A(?!\p{Space}*\z).*\S/, message: "は空白文字だけで投稿できません" }, length: { maximum: 5000 }
end