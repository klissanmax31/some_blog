class Rate < ApplicationRecord
  belongs_to :post
  validates_presence_of :value
end
