class GroupChat < ApplicationRecord
  has_many :group_chat_messages, dependent: :destroy
  has_many :group_chat_members, dependent: :destroy
  has_many :users, through: :group_chat_members

  validates :title, presence: true

  def member?(user)
    group_chat_members.exists?(user: user)
  end

  def free?
    group_chat_members.exists?(role: :free)
  end
end
