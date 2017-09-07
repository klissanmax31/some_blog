class PostValidator < SimpleDelegator
  include ActiveModel::Validations

  validates_presence_of :user_id, :title, :content, :user_ip
end
