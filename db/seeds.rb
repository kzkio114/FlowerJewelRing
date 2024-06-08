# ギフトカテゴリを作成
# 既存のギフトカテゴリを使用
plant_category = GiftCategory.find_or_create_by!(name: '植物') do |category|
  category.description = '美しい植物のギフト'
end


# 各日付の花と花言葉を配列に格納
flowers = [
  ["フクジュソウ", "幸せを招く"],
  ["ハルサザンカ", "困難に勝つ"],
  ["ブルースター", "幸せな愛"],
  ["ラッパスイセン", "再生"],
  ["マンリョウ", "予言"],
  ["ナワシロイチゴ", "恩恵"],
  ["ブルーデイジー", "恵まれて"],
  ["グズマニア", "完璧"],
  ["スイートピー", "永遠の喜び"],
  ["リカステ", "快活"],
  ["オウバイ", "高貴"],
  ["チューリップ（黄）", "正直"],
  ["ピグミーランタン", "印象"],
  ["キンギョソウ", "欲望"],
  ["サクラソウ", "忠実"],
  ["ハナシノブ", "野生美"],
  ["クリスマスローズ", "大切な人"],
  ["スプレーギク", "寛大"],
  ["サクシフラガ", "自信"],
  ["ネコヤナギ", "素直"],
  ["ウメ（紅）", "忠実"],
  ["バイモ", "飾らない心"],
  ["ミズバショウ", "決心"],
  ["ロウバイ", "温かみ"]
]

# 各日付の花と花言葉に対応するギフトを作成
flowers.each_with_index do |(flower, message), i|
  Gift.find_or_create_by!(
    gift_category: plant_category,
    item_name: flower,
    description: message, # 花言葉をdescriptionに保存
    color: 'green',
    image_url: "assets/#{i+10}.webp", # 画像のURLは適宜調整してください
    sender_message: "" # sender_messageは空にしておく
  )
end

puts "シードデータの作成が完了しました。"


# # カテゴリを作成
# categories = ['家庭', '仕事', '健康', '金銭', '人間関係'].map do |name|
#   Category.find_or_create_by!(name: name)
# end

# puts 'カテゴリとコンサルテーションのデータが生成されました。'
