class Reply < ApplicationRecord
  belongs_to :consultation
  belongs_to :user

  validates :content, presence: true
end