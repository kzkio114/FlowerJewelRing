class GroupChatMember < ApplicationRecord
  belongs_to :group_chat
  belongs_to :user

  enum role: { member: 0, admin: 1, owner: 2 }
end