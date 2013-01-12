class Comment < ActiveRecord::Base
  attr_accessible :body, :pin_id, :user_id
  
  belongs_to :user
  belongs_to :pin,  :counter_cache => true
  
  validates_presence_of :pin, :user
  validates_length_of :body, :minimum => 1
end
