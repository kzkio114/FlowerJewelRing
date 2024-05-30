# ユーザーを作成
User.create!(name: 'Giver1', email: 'gi@example.com', password: 'password')
User.create!(name: 'Receiver1', email: 'recei@example.com', password: 'password')

# ギフトカテゴリを作成
plant_category = GiftCategory.create!(name: '植物', description: '美しい植物のギフト')
gem_category = GiftCategory.create!(name: '宝石', description: '価値ある宝石のギフト')

# 既存のユーザーとギフトカテゴリを使用してギフトを作成
giver = User.find_by(email: 'gi@example.com')
receiver = User.find_by(email: 'recei@example.com')

# # 植物ギフトを追加
# 5.times do |i|
#   Gift.create!(
#     giver: giver,
#     receiver: receiver,
#     gift_category: plant_category,
#     item_name: 'たんぽぽ',
#     message: "たんぽぽのギフト #{i+1}"
#   )
# end

# 宝石ギフトを追加
10.times do |i|
  Gift.create!(
    giver: giver,
    receiver: receiver,
    gift_category: gem_category,
    item_name: 'ルビー',
    color: 'green',
    image_url: 'assets/3.webp',
    message: "ルビーのギフト #{i+1}"
  )
end

10.times do |i|
  Gift.create!(
    giver: giver,
    receiver: receiver,
    gift_category: plant_category,
    item_name: '椿',
    color: 'green',
    image_url: 'assets/2.webp',
    message: "椿 #{i+1}",
  )
end

# # カテゴリを作成
# categories = ['家庭', '仕事', '健康', '金銭', '人間関係'].map do |name|
#   Category.find_or_create_by!(name: name)
# end

# # 各カテゴリに対してコンサルテーションを追加
# categories.each_with_index do |category, index|
#   5.times do |i|
#     Consultation.create!(
#       user_id: User.first.id, # 適宜ユーザーIDを設定
#       category_id: category.id,
#       title: "#{category.name}に関する悩み #{i+1}",
#       content: "#{category.name}に関する詳細な内容 #{i+1}。解決策を求めています。"
#     )
#   end
# end

# puts 'カテゴリとコンサルテーションのデータが生成されました。'
