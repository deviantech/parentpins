class Category < ActiveRecord::Base
  has_many :boards
  has_many :pins
  attr_accessible :name
end
