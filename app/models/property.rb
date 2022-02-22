class Property < ApplicationRecord
  has_many :deals
  belongs_to :seller
end
