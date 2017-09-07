class UserValidator < SimpleDelegator
  include ActiveModel::Validations

  validates_presence_of :login
end
