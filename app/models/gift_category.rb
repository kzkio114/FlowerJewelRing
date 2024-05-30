class GiftCategory < ApplicationRecord
  has_many :gifts, dependent: :destroy
end