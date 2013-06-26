class Import < ActiveRecord::Base
  attr_accessible :count, :source
  belongs_to :user
  has_many :pins
  
  validates_presence_of :source
  validates_numericality_of :attempted, :minimum => 1
end
