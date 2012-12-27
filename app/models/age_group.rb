class AgeGroup < ActiveRecord::Base
  has_many :boards
  attr_accessible :name
end
