class Property < ApplicationRecord
  has_many :property_surveys
  has_many :deals
  belongs_to :seller
end
