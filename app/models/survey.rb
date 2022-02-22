class Survey < ApplicationRecord
  has_many :realtor_surveys
  has_many :seller_surveys
end
