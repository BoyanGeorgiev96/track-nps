class Deal < ApplicationRecord
  belongs_to :realtor
  belongs_to :seller
  belongs_to :property
end
