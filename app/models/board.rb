class Board < ActiveRecord::Base
  extend Searchable
  mount_uploader :cover, BoardCoverUploader

  belongs_to :user
  belongs_to :category
  belongs_to :cover_source, :class_name => 'Pin'
  has_many :pins, :dependent => :destroy, :after_add => :auto_set_cover_from_pin, :before_remove => :update_cover_before_pin_removed, :inverse_of => :board
  has_many :comments, :dependent => :destroy, :as => :commentable
  
  attr_protected :id, :created_at, :updated_at, :slug

  extend FriendlyId
  friendly_id :name, :use => [:slugged, :scoped], :scope => :user
  
  validates_presence_of :user, :category, :slug
  validates_length_of :name, :minimum => 2
  validates_uniqueness_of :name, :scope => :user_id
  
  after_save :update_pin_settings
  before_destroy :clean_redis
  after_create :apply_followers_from_user
  
  scope :in_category, lambda {|cat|
    cat.blank? ? where('1=1') : where({:category_id => cat.id})
  }
  scope :newest_first, order('id DESC')
  scope :with_pins, where('pins_count > ?', 0)
  scope :trending, order('trend_position DESC').where('pins_count > ?', 0)
    
  # TODO: cache these in redis or something, to prevent n+1 calls on board index pages?
  def thumbnail_urls(n = 4)
    pins.newest_first.not_ids(cover_source_id || 0).limit(n).collect{ |p| p.image.v55.url }
  end
  
  def set_cover_source(sid)
    if source = pins.find_by_id(sid)
      update_attributes(:cover => source.image, :cover_source_id => source.id)
    else
      auto_set_cover_from_pin(pins.first)
    end
  end
  
  def auto_set_cover_from_pin(pin)
    return true unless cover_source_id.blank?
    if pin && pin.image
      update_attribute :cover, pin.image
    else
      update_attribute :remove_cover, true
    end
  end
  
  def update_cover_before_pin_removed(pin)
    return true unless cover_source_id.blank? || cover_source_id == pin.try(:id)
    
    if next_pin = pins.with_image.newest_first.where(['id <> ?', pin.try(:id)]).first
      update_attribute :cover, next_pin.image
    else
      update_attribute :remove_cover, true
    end
  end

  # ======================================
  # = Users can follow individual boards =
  # ======================================
  
  def followers_even_indirectly_count
    Rails.redis.sunion(redis_name__followed_by, user.redis_name__followed_by).count
  end
  
  def direct_followers_count
    Rails.redis.scard(redis_name__followed_by)
  end
  
  def directly_followed_by_ids
    Rails.redis.smembers(redis_name__followed_by)
  end
  
  def redis_name__followed_by
    "b:#{self.id}:followed_by"
  end

  protected
  
  def update_pin_settings
    return true unless category_id_changed?
    
    pins.find_each do |pin|
      pin.send(:copy_board_settings)
      pin.save
    end
  end

  def apply_followers_from_user
    user.direct_followers.each do |u|
      u.follow_board(self)
    end
  end

  def clean_redis
    User.where(:id => directly_followed_by_ids).find_each do |u|
      u.unfollow(self)
    end
    Rails.redis.del(redis_name__followed_by)
  end
    
end
