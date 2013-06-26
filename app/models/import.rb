class Import < ActiveRecord::Base
  attr_accessible :attempted, :source, :user_agent
  belongs_to :user
  has_many :pins
  
  validates_presence_of :source
  validates_numericality_of :attempted, :minimum => 1
end
