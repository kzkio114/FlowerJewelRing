# # 組織を作成または取得
# org = Organization.find_or_create_by!(name: "Test Organization")

# # テストユーザーを作成または取得
# user = User.find_or_create_by!(email: "test@example.com") do |u|
#   u.name = "Test User"
#   u.password_digest = Digest::SHA256.hexdigest("password")
#   u.display_name = "TestUser"
# end

# # ユーザーと組織の関係を確実に作成
# UserOrganization.create!(
#   user: user,
#   organization: org,
#   joined_at: DateTime.now
# )

# 10.times do |i|
#   giver = User.find_or_create_by!(email: "giver#{i+1}@example.com") do |g|
#     g.name = "Giver #{i+1}"
#     g.password_digest = Digest::SHA256.hexdigest("password#{i+1}")
#     g.display_name = "Giver#{i+1}"
#   end

#   receiver = User.find_or_create_by!(email: "receiver#{i+2}@example.com") do |r|
#     r.name = "Receiver #{i+2}"
#     r.password_digest = Digest::SHA256.hexdigest("password#{i+2}")
#     r.display_name = "Receiver#{i+2}"
#   end

#   category = GiftCategory.find_or_create_by!(name: "Category #{i+1}")

#   Gift.create!(
#     giver: giver,
#     receiver: receiver,
#     gift_category: category,
#     message: "ギフトのメッセージ#{i+1}"
#   )
# end


# # データベースに既存のユーザーとギフトカテゴリがあることを確認または作成
# unless User.exists?
#   User.create!(email: "user@example.com", name: "Demo User", password_digest: Digest::SHA256.hexdigest("password"))
# end

# unless GiftCategory.exists?
#   GiftCategory.create!(name: "Sample Category")
# end

# # Userレコードを作成
# User.create!(name: 'Giver', email: 'giver@example.com', password: 'password')
# User.create!(name: 'Receiver', email: 'receiver@example.com', password: 'password')

# # GiftCategoryレコードを作成
# GiftCategory.create!(name: 'Category 1')

# # 既存のユーザーとギフトカテゴリを使用してギフトを作成
# giver = User.first
# receiver = User.last # 別のユーザーがいる場合、それを利用
# category = GiftCategory.first

# # 新しいギフトを追加
# 48.times do |i|
#   Gift.create!(
#     giver: giver,
#     receiver: receiver,
#     gift_category: category,
#     message: "Extra Gift #{i+1}"
#   )
# end

# カテゴリを作成
categories = ['家庭', '仕事', '健康', '金銭', '人間関係'].map do |name|
  Category.find_or_create_by!(name: name)
end

# 各カテゴリに対してコンサルテーションを追加
categories.each_with_index do |category, index|
  5.times do |i|
    Consultation.create!(
      user_id: User.first.id, # 適宜ユーザーIDを設定
      category_id: category.id,
      title: "#{category.name}に関する悩み #{i+1}",
      content: "#{category.name}に関する詳細な内容 #{i+1}。解決策を求めています。"
    )
  end
end

puts 'カテゴリとコンサルテーションのデータが生成されました。'
