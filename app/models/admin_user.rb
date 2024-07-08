class AdminUser < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum admin_role: { super_admin: 0, admin: 1, moderator: 2 } # 役割の定義
end