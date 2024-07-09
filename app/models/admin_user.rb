class AdminUser < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum admin_role: { organization_admin: 0, super_admin: 1 }

  validates :user_id, presence: true
  validates :organization_id, presence: true
  validates :admin_role, presence: true
end