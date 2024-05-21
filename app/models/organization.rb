class Organization < ApplicationRecord
  # UserOrganizationモデルを通じてUserモデルと多対多の関係を持つ
  has_many :user_organizations
  has_many :users, through: :user_organizations
end