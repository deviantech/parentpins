class Featured < ActiveRecord::Base
  attr_accessible :description, :user_id
  
  belongs_to :user
  
  scope :random, order('rand()')
  scope :with_user, includes(:user)
end
