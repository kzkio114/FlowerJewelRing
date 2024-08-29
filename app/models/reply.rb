class Reply < ApplicationRecord
  belongs_to :consultation
  belongs_to :user

  validates :content, presence: { message: "を入力してください" }, format: { with: /\A(?!\p{Space}*\z).*\S/, message: "は空白文字だけで投稿できません" }, length: { maximum: 5000 }

  enum tone: { positive: '肯定', neutral: '普通', negative: '否定' }, _suffix: true

# 返信が匿名であるかどうかを判定するメソッド
   def name_or_anonymous
    anonymous ? '匿名' : user.name
  end
end