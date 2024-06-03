# 例えば、Userモデルが存在し、最初のユーザーをgiver、2番目のユーザーをreceiverとする場合
giver = User.first
receiver = User.second

# ギフトカテゴリを作成
plant_category = GiftCategory.create!(name: '植物', description: '美しい植物のギフト')
#gem_category = GiftCategory.create!(name: '宝石', description: '価値ある宝石のギフト')


# 各日付の花と花言葉を配列に格納
flowers = [
  ["フクジュソウ", "幸せを招く"],
  ["ハルサザンカ", "困難に勝つ"],
  ["ストレリチア", "ひとり占め"],
  ["ブルースター", "幸せな愛"],
  ["ラッパスイセン", "再生"],
  ["カーネーション（ピンク）", "熱愛"],
  ["アッツザクラ", "愛を待つ"],
  ["マンリョウ", "予言"],
  ["ユキワリソウ", "期待"],
  ["ナワシロイチゴ", "恩恵"],
  ["コチョウラン（白）", "愛をあなたへ"],
  ["カンツバキ", "謙譲"],
  ["マンサク", "新鮮"],
  ["ブルーデイジー", "恵まれて"],
  ["ポピー（八重）", "やすらぎ"],
  ["オキザリス", "ひたむきな愛"],
  ["スイカズラ", "愛の絆"],
  ["グズマニア", "完璧"],
  ["ストック（八重）", "永遠の美"],
  ["スイートピー", "永遠の喜び"],
  ["スイセン", "自己愛"],
  ["リカステ", "快活"],
  ["オウバイ", "高貴"],
  ["ヒヤシンス（紫）", "優しくかわいい"],
  ["チューリップ（黄）", "正直"],
  ["ピグミーランタン", "印象"],
  ["マダガスカルジャスミン", "自意識"],
  ["キンギョソウ", "欲望"],
  ["スミレ", "誠実な愛"]
]

# 各日付の花と花言葉に対応するギフトを作成
flowers.each_with_index do |(flower, message), i|
  Gift.create!(
    giver: giver,
    receiver: receiver,
    gift_category: plant_category,
    item_name: flower,
    description: message, # 花言葉をdescriptionに保存
    color: 'green',
    #image_url: "assets/#{i+1}.webp", # 画像のURLは適宜調整してください
    sender_message: "", # sender_messageは空にしておく
  )
end

# # カテゴリを作成
# categories = ['家庭', '仕事', '健康', '金銭', '人間関係'].map do |name|
#   Category.find_or_create_by!(name: name)
# end

# puts 'カテゴリとコンサルテーションのデータが生成されました。'
