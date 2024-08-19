class GiftTemplate < ApplicationRecord
  belongs_to :gift_category

  validates :name, presence: true
  validates :gift_category_id, presence: true
end
