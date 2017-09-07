class RateValidator < SimpleDelegator
  include ActiveModel::Validations

  validates_presence_of :post_id, :value
end
