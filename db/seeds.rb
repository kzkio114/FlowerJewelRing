# # ギフトカテゴリを作成
# # 既存のギフトカテゴリを使用
# plant_category = GiftCategory.find_or_create_by!(name: '植物') do |category|
#   category.description = '美しい植物のギフト'
# end

# # 各日付の花と花言葉or宝石言葉を配列に格納
# flowers = [
#   ["フクジュソウ", "幸せを招く"],
#   ["ハルサザンカ", "困難に勝つ"],
#   ["ブルースター", "幸せな愛"],
#   ["ラッパスイセン", "再生"],
#   ["マンリョウ", "予言"],
#   ["ナワシロイチゴ", "恩恵"],
#   ["ブルーデイジー", "恵まれて"],
#   ["グズマニア", "完璧"],
#   ["スイートピー", "永遠の喜び"],
#   ["リカステ", "快活"],
#   ["オウバイ", "高貴"],
#   ["チューリップ（黄）", "正直"],
#   ["ピグミーランタン", "印象"],
#   ["キンギョソウ", "欲望"],
#   ["サクラソウ", "忠実"],
#   ["ハナシノブ", "野生美"],
#   ["クリスマスローズ", "大切な人"],
#   ["スプレーギク", "寛大"],
#   ["サクシフラガ", "自信"],
#   ["ネコヤナギ", "素直"],
#   ["ウメ（紅）", "忠実"],
#   ["バイモ", "飾らない心"],
#   ["ミズバショウ", "決心"],
#   ["ロウバイ", "温かみ"]
# ]

# # 各日付の花と花言葉or宝石言葉に対応するギフトを作成
# flowers.each_with_index do |(flower, message), i|
#   Gift.find_or_create_by!(
#     gift_category: plant_category,
#     item_name: flower,
#     description: message, # 花言葉or宝石言葉をdescriptionに保存
#     color: 'green',
#     image_url: "#{i+10}.webp", # 画像のURLは適宜調整してください
#     sender_message: "" # sender_messageは空にしておく
#   )
# end




# # puts "シードデータの作成が完了しました。"


# # カテゴリを作成
# categories = ['家庭', '仕事', '健康', '金銭', '人間関係', 'プログラミング関係'].map do |name|
#   Category.find_or_create_by!(name: name)
# end

# puts 'カテゴリとコンサルテーションのデータが生成されました。'

# # admin
# # ユーザーを見つけます

#  user = User.find_by(email: 'kzkio114@gmail.com')


# # # 既存のAdminUserレコードを見つけるか、新しいレコードを作成します
#  admin_user = AdminUser.find_or_create_by(user: user, organization_id: 1)

# # # admin_roleをsuper_adminに設定します
#  admin_user.update(admin_role: :super_admin)




# # ギフトカテゴリを作成

# # 既存のギフトカテゴリを使用
# plant_category = GiftCategory.find_or_create_by!(name: '植物') do |category|
#   category.description = '美しい植物のギフト'
# end

# # 各日付の花と花言葉or宝石言葉を配列に格納
# flowers = [
#   ["フクジュソウ", "幸せを招く"],
#   ["ハルサザンカ", "困難に勝つ"],
#   ["ブルースター", "幸せな愛"],
#   ["ラッパスイセン", "再生"],
#   ["マンリョウ", "予言"],
#   ["ナワシロイチゴ", "恩恵"],
#   ["ブルーデイジー", "恵まれて"],
#   ["グズマニア", "完璧"],
#   ["スイートピー", "永遠の喜び"],
#   ["リカステ", "快活"],
#   ["オウバイ", "高貴"],
#   ["チューリップ（黄）", "正直"],
#   ["ピグミーランタン", "印象"],
#   ["キンギョソウ", "欲望"],
#   ["サクラソウ", "忠実"],
#   ["ハナシノブ", "野生美"],
#   ["クリスマスローズ", "大切な人"],
#   ["スプレーギク", "寛大"],
#   ["サクシフラガ", "自信"],
#   ["ネコヤナギ", "素直"],
#   ["ウメ（紅）", "忠実"],
#   ["バイモ", "飾らない心"],
#   ["ミズバショウ", "決心"],
#   ["ロウバイ", "温かみ"]
# ]

# # 各日付の花と花言葉or宝石言葉に対応するギフトテンプレートを作成
# flowers.each_with_index do |(flower, message), i|
#   GiftTemplate.find_or_create_by!(
#     gift_category: plant_category,
#     name: flower,
#     description: message, # 花言葉or宝石言葉をdescriptionに保存
#     color: 'green',
#     image_url: "#{i+10}.webp" # 画像のURLは適宜調整してください
#   )
# end

# 宝石カテゴリを作成
jewel_category = GiftCategory.find_or_create_by!(name: '宝石') do |category|
  category.description = '美しい宝石のギフト'
end

# 宝石の種類と説明を配列に格納
jewels = [
  ["オニキス", "夫婦の幸福 厄除け 秘密"],
  ["アクアマリン", "勇敢 聡明 沈着"],
  ["琥珀", "活性 長寿 繁栄"],
  ["スピネル", "愛情 幸福 ポジティブ"],
  ["ルビー", "純愛 仁愛 情熱的な愛"],
  ["エメラルド", "愛 癒し 聡明"],
  ["サファイア", "愛情 誠実 徳望"],
  ["アメジスト", "心の平和 真実の愛 誠実"],
  ["オパール", "純真無垢 幸運 忍耐"],
  ["ダイヤモンド", "純愛 純潔 清浄無垢"],
  ["真珠", "健康 純粋 長寿"],
  ["トパーズ", "成功 希望 誠実"],
  ["ペリドット", "太陽の象徴 夫婦和合 厄除け"],
  ["シトリン", "繁栄 幸運 成功"],
  ["タンザナイト", "神秘 冷静 誇り高い"],
  ["ガーネット", "真実 友愛 忠実"]
]

# 各宝石に対応するギフトテンプレートを作成
jewels.each_with_index do |(jewel, message), i|
  GiftTemplate.find_or_create_by!(
    gift_category: jewel_category,
    name: jewel,
    description: message, # 宝石の意味をdescriptionに保存
    color: 'blue',
    image_url: "gem#{i+1}.webp" # 画像のURLは適宜調整してください
  )
end

puts "宝石カテゴリとギフトが作成されました。"