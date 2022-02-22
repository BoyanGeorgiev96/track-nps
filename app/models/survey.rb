class Survey < ApplicationRecord
  has_many :deal_surveys
  has_many :realtor_surveys
  has_many :seller_surveys
  has_many :property_surveys
end
