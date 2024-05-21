class UserOrganization < ApplicationRecord
  # UserモデルとOrganizationモデルとそれぞれ1対多の関係を持つ
  belongs_to :user
  belongs_to :organization
end