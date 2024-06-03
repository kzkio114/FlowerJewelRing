class Chat < ApplicationRecord
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'

  validates :sender_id, presence: true
  validates :receiver_id, presence: true
  validates :message, presence: true

  before_save :encrypt_message

  def encrypt_message
    self.encrypted = Base64.encode64(message) # 簡易的な暗号化。実際にはより強力な暗号化方法を使用してください。
  end

  def decrypted_message
    Base64.decode64(encrypted)
  end
end
