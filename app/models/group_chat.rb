class GroupChat < ApplicationRecord
  has_many :group_chat_members
  has_many :group_chat_messages
end