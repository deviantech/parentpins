class Board < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  belongs_to :age_group
  has_many :pins, :dependent => :destroy
  
  attr_protected :id
  
  validates_presence_of :user, :category, :age_group
  validates_length_of :name, :minimum => 2
  validates_uniqueness_of :name, :scope => :user_id
end
