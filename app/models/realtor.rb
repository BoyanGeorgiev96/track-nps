class Realtor < ApplicationRecord
has_many :realtor_surveys
has_many :deals
end
