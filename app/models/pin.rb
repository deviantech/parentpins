class Pin < ActiveRecord::Base
  attr_accessible :kind, :name, :description, :price, :url, :user_id, :age_group_id, :board_id, :category_id, :image

  VALID_TYPES = %w(gift article idea)

  mount_uploader :image, PinImageUploader

  belongs_to :user
  belongs_to :via
  belongs_to :board
  belongs_to :category
  belongs_to :age_group
  
  validates_presence_of :user, :name, :board, :category, :age_group
  validates_inclusion_of :kind, :in => VALID_TYPES
  validates_length_of :description, :maximum => 255, :allow_blank => true
  validate :url_format
  
  scope :by_kind, lambda {|kind|
    kind.blank? ? where('1=1') : where({:kind => kind})
  }
  
  # TODO: IMPLEMENT THESE
  def like_count; 2; end
  def repin_count; 5; end
  def comment_count; 3; end
  
  protected
  
  def url_format
    errors.add(:url, "doesn't look like a valid link") unless url.to_s.match(/\Ahttps?:\/\//)
  end
end
