class Category < ActiveRecord::Base
  has_many :boards
  attr_accessible :name
end
