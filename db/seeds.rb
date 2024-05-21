# 組織を作成または取得
org = Organization.find_or_create_by(name: "Test Organization")

# テストユーザーを作成または取得
user = User.find_or_create_by(email: "test@example.com") do |user|
  user.name = "Test User"
  user.password_digest = Digest::SHA256.hexdigest("password")
  user.display_name = "TestUser"
end

# ユーザーと組織の関係を作成
UserOrganization.create!(
  user: user,
  organization: org,
  joined_at: DateTime.now
)