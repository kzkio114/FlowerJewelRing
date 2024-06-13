class GroupChatMessage < ApplicationRecord
  belongs_to :group_chat
  belongs_to :user

  validates :message, presence: true
end