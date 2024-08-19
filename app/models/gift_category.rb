class GiftCategory < ApplicationRecord
  has_many :gifts, dependent: :destroy
  has_many :gift_templates
end