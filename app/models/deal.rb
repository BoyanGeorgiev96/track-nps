class Deal < ApplicationRecord
  has_many :deal_surveys
  belongs_to :realtor
  belongs_to :seller
  belongs_to :property
end
