class User < ActiveRecord::Base
  extend Searchable
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  mount_uploader :avatar,       AvatarUploader
  mount_uploader :cover_image,  CoverImageUploader
  
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :provider, :uid, :avatar, :interested_category_ids, :kids, :bio, :avatar_cache, :cover_image, :cover_image_cache, :current_password
  
  has_many :boards,       :dependent => :destroy
  has_many :pins,         :dependent => :destroy
  has_many :pins_via_me,                            :class_name => 'Pin',   :foreign_key => 'via_id'
  has_many :pins_originally_from_me,                :class_name => 'Pin',   :foreign_key => 'originally_from_id'
  has_many :comments,     :dependent => :destroy
  
  has_many :feedbacks
  
  extend FriendlyId
  friendly_id :username
  
  validates_uniqueness_of :username, :allow_blank => false
  validates_format_of :username, :with => /\A[a-z0-9]+\z/i
  validates_numericality_of :kids, :allow_blank => true
  validate :valid_username
  before_destroy :clean_redis

  # Used by searchable
  scope :newest_first, order('id DESC')

  def name
    username.to_s.titleize
  end


  # If password required for update, try. Otherwise just to update. Not the cleanest combination of forms...
  def update_maybe_with_password(params)
    if params[:email] != email || !params[:password].blank? || !params[:password_confirmation].blank?
      update_with_password(params)
    else
      params.delete(:password)
      params.delete(:password_confirmation)
      params.delete(:current_password)
      update_attributes(params)
    end
  end

  # ================================
  # = REDIS: Interested Categories =
  # ================================
  def interested_category_ids=(ids)
    Rails.redis.del(redis_name__categories)
    add_interested_categories(ids)
  end

  def interested_category_ids
    Rails.redis.smembers(redis_name__categories)
  end

  def interested_categories
    Category.where(:id => interested_category_ids)
  end
  
  def add_interested_categories(cats)
    return if cleaned_ids(cats).blank?
    Rails.redis.sadd(redis_name__categories, cleaned_ids(cats))
  end
  
  def remove_interested_categories(cats)
    return if cleaned_ids(cats).blank?
    Rails.redis.srem(redis_name__categories, cleaned_ids(cats))
  end
  

  # ==============================
  # = REDIS: Following/Followers =
  # ==============================
  
  def followers
    User.where(:id => follower_ids)
  end

  def following
    User.where(:id => following_ids)
  end
  
  def follower_ids
    Rails.redis.smembers(redis_name__followers)
  end
  
  def following_ids
    Rails.redis.smembers(redis_name__following)
  end
  
  def following?(user)
    user = User.find_by_id(user) unless user.is_a?(User)
    return nil if user.blank? || user.id == self.id
    
    Rails.redis.sismember(redis_name__following, user.id)
  end
  
  def followed_by?(user)
    user = User.find_by_id(user) unless user.is_a?(User)
    return nil if user.blank? || user.id == self.id
    
    Rails.redis.sismember(redis_name__followers, user.id)
  end
  
  def follow(user)
    user = User.find_by_id(user) unless user.is_a?(User)
    return nil if user.blank? || user.id == self.id
    
    Rails.redis.sadd(redis_name__following, user.id)
    Rails.redis.sadd(user.redis_name__followers, self.id)
  end

  def unfollow(user)
    user = User.find_by_id(user) unless user.is_a?(User)
    return nil if user.blank? || user.id == self.id
    
    Rails.redis.srem(redis_name__following, user.id)
    Rails.redis.srem(user.redis_name__followers, self.id)
  end

  def followers_count
    Rails.redis.scard(redis_name__followers)
  end
      
  def following_count
    Rails.redis.scard(redis_name__following)
  end
  
  
  # ==========================================================
  # = REDIS: Liked Pins (implementation partially in pin.rb) =
  # ==========================================================

  def likes
    Pin.where(:id => like_ids)
  end
    
  def like_ids
    Rails.redis.smembers(redis_name__likes)
  end

  def likes_count
    Rails.redis.scard(redis_name__likes)
  end
  
  def likes?(pin)
    pin = pin.is_a?(Pin) ? pin : Pin.find(pin)
    
    Rails.redis.sismember(redis_name__likes, pin.id)
  end
  
  def like(pin)
    pin = pin.is_a?(Pin) ? pin : Pin.find(pin)
    
    Rails.redis.sadd(redis_name__likes, pin.id)
    Rails.redis.sadd(pin.redis_name__liked_by, self.id)
  end
  
  def unlike(pin)
    pin = pin.is_a?(Pin) ? pin : Pin.find(pin)

    Rails.redis.srem(redis_name__likes, pin.id)
    Rails.redis.srem(pin.redis_name__liked_by, self.id)    
  end
  
  # ======================
  # = REDIS: queue names =
  # ======================    
  def redis_name__categories
    "u:#{self.id}:categories"
  end
  
  def redis_name__followers
    "u:#{self.id}:followers"
  end
  
  def redis_name__following
    "u:#{self.id}:following"
  end

  def redis_name__likes
    "u:#{self.id}:likes"
  end

  protected
  
  def valid_username
    return if username.blank?
    errors.add(:username, 'cannot start with a number') if username.match(/\A\d/)
  end
  
  def cleaned_ids(cats)
    Array(cats).select{|c| !c.blank?}.map{ |cat| cat.respond_to?(:id) ? cat.id : cat }.uniq
  end

  def clean_redis
    # Clear self from other objects' redis entries
    following.each {|u| unfollow(u) }
    followers.each {|u| u.unfollow(self) }
    likes.each {|l| unlike(l)}
    
    # Remove my redis objects
    Rails.redis.del(redis_name__categories)
    Rails.redis.del(redis_name__following)
    Rails.redis.del(redis_name__followers)
    Rails.redis.del(redis_name__likes)
  end
  
end
