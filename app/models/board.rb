class Board < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  belongs_to :age_group
  
  attr_accessible :age_group_id, :category_id, :description, :name, :user_id
  
  validates_presence_of :user, :category, :age_group
end
