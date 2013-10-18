class Category < ActiveRecord::Base
  has_many :boards
  has_many :pins
  attr_accessible :name
  
  validates_uniqueness_of :name, :allow_blank => false  
  
  default_scope { order('name ASC') }
end
