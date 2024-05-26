class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :discord, :twitter, :github, :line]

  has_many :user_organizations
  has_many :organizations, through: :user_organizations

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first_or_initialize

    user.name = data['name']
    user.password = Devise.friendly_token[0, 20] if user.new_record?
    user.save!
    user
  end
end
