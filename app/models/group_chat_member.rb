class GroupChatMember < ApplicationRecord
  belongs_to :group_chat
  belongs_to :user

  enum role: { member: 0, admin: 1, free: 2 }

   # freeロールはadmin権限を持つように扱う
   def admin?
    role == 'admin' || role == 'free'
  end
end