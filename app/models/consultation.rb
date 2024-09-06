class Consultation < ApplicationRecord
  searchkick word_middle: [:title, :content, :category_name, :user_name]
  before_create :set_default_display_choice

  def search_data
    {
      title: title,
      content: content,
      category_name: category.name,
      user_name: anonymized_name # 匿名対応の名前を使う
    }
  end

  belongs_to :user
  belongs_to :category
  has_many :replies, dependent: :destroy

  validates :title, presence: { message: "を入力してください" }, format: { with: /\A(?!\p{Space}*\z).*\S/, message: "は空白文字だけで投稿できません" }, length: { maximum: 50 }
  validates :content, presence: { message: "を入力してください" }, format: { with: /\A(?!\p{Space}*\z).*\S/, message: "は空白文字だけで投稿できません" }, length: { maximum: 5000 }

  enum desired_reply_tone: { positive: '肯定', neutral: '普通', negative: '否定' }, _suffix: true

  # 匿名かどうかを判定し、匿名の場合は '匿名' を返す
  def anonymized_name
    display_choice == 'anonymous' ? '匿名' : user.name
  end

  private

  def set_default_display_choice
    self.display_choice ||= 'name'
  end
end