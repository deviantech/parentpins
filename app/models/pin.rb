require 'searchable'
class Pin < ActiveRecord::Base
  extend Searchable
  attr_accessible :kind, :name, :description, :price, :url, :user_id, :age_group_id, :board_id, :category_id, :image, :image_cache

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
  
  before_update   :update_board_images_on_change
  after_create    :update_board_add_image
  before_destroy  :update_board_remove_image
  before_destroy  :clean_redis
  
  scope :by_kind, lambda {|kind|
    kind.blank? ? where('1=1') : where({:kind => kind})
  }
  scope :in_categories, lambda {|cats|
    cats.blank? ? where('1=1') : where({:category_id => Array(cats).map(&:id)})
  }
  scope :pinned_by, lambda {|uids|
    where({:user_id => uids})
  }
  
  scope :with_image, where('image <> ""')

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
      pin.board_id ||= user.boards.first.try(:id)
      pin
    else
      user.pins.new(other_params)
    end
    
    [source, the_pin]
  end
  
  # ===========================================================
  # = REDIS: Liked Pins (implementation partially in user.rb) =
  # ===========================================================

  def liked_by
    User.where(:id => liked_by_ids)
  end
  
  def liked_by_ids
    Rails.redis.smembers(redis_name__liked_by)
  end
  
  def liked_by_count
    Rails.redis.scard(redis_name__liked_by)
  end
  
  # ======================
  # = REDIS: queue names =
  # ======================    
  def redis_name__liked_by
    "p:#{self.id}:liked_by"
  end
    
  protected
  
  def url_format
    errors.add(:url, "doesn't look like a valid link") unless url.to_s.match(/\Ahttps?:\/\//)
  end

  def update_board_images_on_change
    return true unless board_id_changed?
    
    if old = Board.find_by_id(board_id_was)
      old.update_cover_before_pin_removed(self)
    end
    
    if future = Board.find_by_id(board_id)
      future.set_cover_from_pin(self)
    end
  end

  def update_board_add_image
    board.try(:set_cover_from_pin, self)
  end
  
  def update_board_remove_image
    board.try(:update_cover_before_pin_removed, self)
  end
  
  def clean_redis
    # Clear self from other objects' redis entries
    liked_by.each {|u| u.unlike(self) }

    # Remove my redis objects
    Rails.redis.del(redis_name__liked_by)
  end

end
