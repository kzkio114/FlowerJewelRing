class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :discord, :twitter, :github, :line]

  before_create :generate_random_id

  has_many :admin_users
  has_many :organizations, through: :admin_users
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
  has_many :replies, dependent: :destroy
  has_many :user_organizations, dependent: :destroy
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true

  # ユーザーが管理者かどうかを判定するメソッド
  def admin?
    admin_users.exists?
  end

  # ユーザーが特定の組織の管理者かどうかを判定するメソッド
  def admin_for?(organization)
    admin_users.exists?(organization: organization)
  end

  # ユーザーがスーパー管理者かどうかを判定するメソッド
  def super_admin?
    admin_users.exists?(admin_role: :super_admin)
  end

  # 特定の返信者から受け取ったギフトを取得するメソッド
  def received_gifts_from_repliers
    replier_ids = consultations.joins(:replies).pluck('replies.user_id').uniq
    received_gifts.where(giver_id: replier_ids)
  end

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first_or_initialize
  
    if user.new_record?
      # 新規ユーザーの場合のみ、名前と表示名を設定する
      user.name = data['name']
      user.display_name = data['nickname'] || data['name']
      user.password = Devise.friendly_token[0, 20]
      user.save
    end
  
    user
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
      gift.gift_histories.where(read: false).count + (gift.sender_message.present? ? 1 : 0)
    end
  end

  private

  # ランダムな8桁のIDを生成するメソッド
  def generate_random_id
    self.social_id = SecureRandom.hex(4) # 8桁のランダムなIDを生成
  end
end
