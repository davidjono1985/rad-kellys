class Item < ApplicationRecord
  belongs_to :user
  has_many :orders
  has_many :wishlists
  has_one_attached :picture
  
end
