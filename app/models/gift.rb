class Gift < ApplicationRecord
  belongs_to :giver, class_name: 'User', optional: true  # optional: trueを追加
  belongs_to :receiver, class_name: 'User', optional: true  # optional: trueを追加
  belongs_to :gift_category
end