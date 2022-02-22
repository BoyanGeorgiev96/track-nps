class Seller < ApplicationRecord
  has_many :seller_surveys
  has_many :deals
  has_many :properties
end
