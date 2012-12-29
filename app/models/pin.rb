class Pin < ActiveRecord::Base
  attr_accessible :kind, :name, :description, :price, :url, :user_id, :age_group_id, :board_id, :category_id

  VALID_TYPES = %w(gift article idea)

  belongs_to :user
  belongs_to :via
  belongs_to :board
  belongs_to :category
  belongs_to :age_group
  
  validates_presence_of :user, :board, :category, :age_group, :url
  validates_inclusion_of :kind, :in => VALID_TYPES
  validates_length_of :description, :maximum => 255, :allow_blank => true
  
  scope :by_kind, lambda {|kind|
    kind.blank? ? where('1=1') : where({:kind => kind})
  }
end
