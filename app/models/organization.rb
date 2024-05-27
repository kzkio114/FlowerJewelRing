class Organization < ApplicationRecord
  has_many :admin_users
  has_many :user_organizations
  has_many :users, through: :user_organizations
end