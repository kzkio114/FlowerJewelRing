class GroupChatMessage < ApplicationRecord
  belongs_to :group_chat
  belongs_to :user
end