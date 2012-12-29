class Pin < ActiveRecord::Base
  attr_accessible :age_group_id, :board_id, :category_id, :kind, :name, :price, :url, :user_id

  belongs_to :user
  belongs_to :via
  belongs_to :board
  belongs_to :category
  belongs_to :age_group
  
  validates_presence_of :user, :board, :category, :age_group, :url
  validates_inclusion_of :kind, :in => %w(gift article idea)
end
