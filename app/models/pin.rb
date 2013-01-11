class Pin < ActiveRecord::Base
  attr_accessible :kind, :name, :description, :price, :url, :user_id, :age_group_id, :board_id, :category_id, :image

  VALID_TYPES = %w(gift article idea)
  REPIN_ATTRIBUTES = %w(kind name price url age_group_id category_id image)

  mount_uploader :image, PinImageUploader

  belongs_to :user
  belongs_to :via,              :class_name => 'User'
  belongs_to :original_poster,  :class_name => 'User'
  belongs_to :board
  belongs_to :category
  belongs_to :age_group
  
  has_many :comments, :dependent => :destroy
  
  validates_presence_of :user, :name, :board, :category, :age_group
  validates_inclusion_of :kind, :in => VALID_TYPES
  validates_length_of :description, :maximum => 255, :allow_blank => true
  validate :url_format
  
  scope :by_kind, lambda {|kind|
    kind.blank? ? where('1=1') : where({:kind => kind})
  }
  scope :in_categories, lambda {|cats|
    cats.blank? ? where('1=1') : where({:category_id => Array(cats).map(&:id)})
  }
  scope :pinned_by, lambda {|uids|
    where({:user_id => uids})
  }

  # TODO: IMPLEMENT THESE
  def like_count; 2; end
  def repin_count; 5; end
  
  # If a source pin was passed in, copy relevant attributes (repin). Otherwise, generate a clean pin record.
  def self.craft_new_pin(user, source_id, other_params)
    the_pin = if source = !source_id.blank? && Pin.find_by_id(source_id)
      pin = Pin.new
      REPIN_ATTRIBUTES.each do |k|
        pin.send("#{k}=", source.send(k))
      end
      pin.attributes = other_params
      
      pin.original_poster = source.original_poster ? source.original_poster : source.user
      pin.original_poster = nil if pin.original_poster == user
      
      pin.via = source.user unless source.user == user
      pin.user = user
      pin
    else
      user.pins.new(other_params)
    end
    
    [source, the_pin]
  end
    
  protected
  
  def url_format
    errors.add(:url, "doesn't look like a valid link") unless url.to_s.match(/\Ahttps?:\/\//)
  end
end
