class AgeGroup < ActiveRecord::Base
  has_many :pins
  attr_accessible :name
  
  validates_uniqueness_of :name, :allow_blank => false
end
