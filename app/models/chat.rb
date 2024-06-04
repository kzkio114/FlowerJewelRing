class Chat < ApplicationRecord
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'

  validates :sender_id, presence: true
  validates :receiver_id, presence: true
  validates :message, presence: true

  before_save :encrypt_message
  

  def encrypt_message
    self.encrypted = Base64.encode64(message)
    Rails.logger.debug "Encrypted message: #{self.encrypted}"
  end

  def decrypted_message
    decoded_message = Base64.decode64(encrypted).force_encoding('UTF-8')
    Rails.logger.debug "Decrypted message: #{decoded_message}"
    decoded_message
  end
end
