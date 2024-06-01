class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :discord, :twitter, :github, :line]


  has_many :admin_users
  has_many :organizations, through: :user_organizations
  has_many :sent_chats, class_name: 'Chat', foreign_key: 'sender_id'
  has_many :received_chats, class_name: 'Chat', foreign_key: 'receiver_id'
  has_many :consultations
  has_many :sent_gifts, class_name: 'Gift', foreign_key: 'giver_id'
  has_many :received_gifts, class_name: 'Gift', foreign_key: 'receiver_id'
  has_many :group_chat_members
  has_many :group_chat_messages
  belongs_to :organization, optional: true
  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile
  has_many :replies
  has_many :user_organizations, dependent: :destroy
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first_or_initialize
  
    user.name = data['name']
    user.password = Devise.friendly_token[0, 20] if user.new_record?
    unless user.save
      Rails.logger.info("ユーザー保存失敗: #{user.errors.full_messages.to_sentence}")
      return nil
    end
    user
  end
end
