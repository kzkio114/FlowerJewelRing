class User < ApplicationRecord
  has_many :user_organizations
  has_many :organizations, through: :user_organizations
end