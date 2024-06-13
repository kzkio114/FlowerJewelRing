class GroupChat < ApplicationRecord
  has_many :group_chat_messages, dependent: :destroy
  has_many :group_chat_members, dependent: :destroy
end