class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :discord, :twitter, :github, :line]

  has_many :admin_users
  has_many :organizations, through: :user_organizations
  has_many :sent_chats, class_name: 'Chat', foreign_key: 'sender_id'
  has_many :received_chats, class_name: 'Chat', foreign_key: 'receiver_id'
  has_many :consultations, dependent: :destroy
  has_many :sent_gifts, class_name: 'Gift', foreign_key: 'giver_id', dependent: :destroy
  has_many :received_gifts, class_name: 'Gift', foreign_key: 'receiver_id', dependent: :destroy
  has_many :group_chat_members
  has_many :group_chat_messages
  belongs_to :organization, optional: true
  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile
  has_many :replies
  has_many :user_organizations, dependent: :destroy
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  # 新しいメソッドを追加
  def received_gifts_from_repliers
    replier_ids = consultations.joins(:replies).pluck('replies.user_id').uniq
    received_gifts.where(giver_id: replier_ids)
  end

  # ユーザーが持つ相談から、未読の返信数を返すメソッド
  def unread_replies_count
    Reply.joins(:consultation)
         .where(consultations: { user_id: id })
         .where(read: false) # read は返信が読まれたかどうかを示す属性
         .count
  end

  # 未読のギフト数を計算するメソッド
  def calculate_unread_gifts_count
    received_gifts_from_repliers.sum do |gift|
      unread_histories_count = gift.gift_histories.where(read: false).count
      sender_message_count = gift.sender_message.present? ? 1 : 0

      Rails.logger.info "Gift ID: #{gift.id}, Unread Histories: #{unread_histories_count}, Sender Message Count: #{sender_message_count}"

      unread_histories_count + sender_message_count
    end
  end
end