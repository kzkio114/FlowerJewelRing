class Consultation < ApplicationRecord
  searchkick word_middle: [:title, :content, :category_name, :user_name]

  def search_data
    {
      title: title,
      content: content,
      category_name: category.name,
      user_name: user.name
    }
  end

  belongs_to :user
  belongs_to :category
  has_many :replies, dependent: :destroy

  validates :title, presence: { message: "を入力してください" }, format: { with: /\A(?!\p{Space}*\z).*\S/, message: "は空白文字だけで投稿できません" }, length: { maximum: 50 }
  validates :content, presence: { message: "を入力してください" }, format: { with: /\A(?!\p{Space}*\z).*\S/, message: "は空白文字だけで投稿できません" }, length: { maximum: 5000 }

  enum desired_reply_tone: { positive: '肯定', neutral: '普通', negative: '否定' }, _suffix: true
end
