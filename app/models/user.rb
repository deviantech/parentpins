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
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :provider, :uid, :avatar, :kids, :bio, :avatar_cache, :cover_image, :cover_image_cache, :current_password, :teacher, :teacher_grade, :teacher_subject
  
  has_many :boards,       :order => 'position ASC',     :dependent => :destroy
  has_many :pins,         :dependent => :destroy
  has_many :pins_via_me,                            :class_name => 'Pin',   :foreign_key => 'via_id'
  has_many :pins_originally_from_me,                :class_name => 'Pin',   :foreign_key => 'originally_from_id'
  has_many :comments,     :dependent => :destroy
  
  has_many :feedbacks
  has_one  :featured, :dependent => :destroy
  
  extend FriendlyId
  friendly_id :username
  
  validates_uniqueness_of :username, :allow_blank => false
  validates_format_of :username, :with => /\A[a-z0-9\.\-\_]+\z/i
  validates_numericality_of :kids, :allow_blank => true, :message => 'must be a number'
  validate :valid_username
  before_destroy :clean_redis

  # Used by searchable
  scope :newest_first, order('id DESC')

  def name
    username.to_s
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


  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
        user.username = data["username"] if user.name.blank?
        user.valid?
      end
    end
  end
  
  def self.find_for_oauth(auth, signed_in_resource = nil)
    user = signed_in_resource
    user ||= User.where(:provider => auth.provider, :uid => auth.uid).first
    user ||= (auth.info.email.blank? ? nil : User.find_by_email(auth.info.email))
    user ||= User.create({
      :username   => auth.extra.raw_info.username,
      :email      => auth.info.email,
      :password   => Devise.friendly_token[0,20]
    })
    
    user.update_attributes(:uid => auth.uid, :provider => auth.provider)
    return user
  end
  
  # Include pins by follower_user_ids or on boards_following_ids, unique
  def activity
    Pin.where(['user_id IN (?) OR board_id IN (?)', users_following_ids, boards_following_ids])
  end

  # ===============================
  # = REDIS: last board pinned to =
  # ===============================

  def last_board_pinned_to_id
    Rails.redis.get(redis_name__last_board).to_i
  end
  
  def set_last_board_pinned_to_id(id)
    Rails.redis.set(redis_name__last_board, id)
  end


  # ==============================
  # = REDIS: Following/Followers =
  # ==============================
  
  # Hard to decide what to show for counts. Most efficient to only show those directly following, but
  # on the "follows" page we had to show all (else you can never see the boards you follow), so on the
  # "followed_by" page we had to follow suit to remain consistent.
  
  # TODO: make uses of this more efficient   
  def following_even_indirectly
    @following_even_indirectly ||= begin
      uids = users_following_ids
      uids += Board.where(:id => boards_following_ids).select('DISTINCT(user_id)')
      User.where(:id => uids.uniq)
    end
  end

  def following_even_indirectly_count
    following_even_indirectly.count
  end

  def followed_by_even_indirectly
    @followed_by_even_indirectly ||= begin
      uids = followed_by_ids
      uids += boards.collect {|b| b.directly_followed_by_ids}
      User.where(:id => uids.flatten.uniq)
    end
  end

  def followed_by_even_indirectly_count
    followed_by_even_indirectly.count
  end
  
  # ids
  
  def followed_by_ids
    Rails.redis.smembers(redis_name__followed_by)
  end
  
  def users_following_ids
    Rails.redis.smembers(redis_name__following_users)
  end
  
  def boards_following_ids
    Rails.redis.smembers(redis_name__following_boards)
  end
  
  # methods
  
  def following?(obj)
    return nil if obj.blank? ||
      (obj.is_a?(User) && obj.id == self.id) ||
      (obj.is_a?(Board) && self.boards.include?(obj))
    
    case obj
    when User then following_user?(obj)
    when Board then following_board?(obj)
    else nil
    end
  end
  
  def following_user?(obj)
    Rails.redis.sismember(redis_name__following_users, obj.id)
  end

  def following_board?(obj)
    Rails.redis.sismember(redis_name__following_boards, obj.id)
  end
  
  def followed_by?(user)
    user = User.find_by_id(user) unless user.is_a?(User)
    return nil if user.blank? || user.id == self.id
    
    Rails.redis.sismember(redis_name__followed_by, user.id)
  end
  
  def follow(obj)
    return nil if obj.blank? ||
      (obj.is_a?(User) && obj.id == self.id) ||
      (obj.is_a?(Board) && self.boards.include?(obj))
    
    case obj
    when User then follow_user(obj)
    when Board then follow_board(obj)
    else nil
    end
  end
    
  def follow_user(obj)
    Rails.redis.sadd(redis_name__following_users, obj.id)
    Rails.redis.sadd(obj.redis_name__followed_by,  self.id)
  end
  
  def follow_board(obj)
    Rails.redis.sadd(redis_name__following_boards,  obj.id)
    Rails.redis.sadd(obj.redis_name__followed_by,     self.id)
  end

  def unfollow(obj)
    return nil if obj.blank? ||
      (obj.is_a?(User) && obj.id == self.id) ||
      (obj.is_a?(Board) && self.boards.include?(obj))
    
    case obj
    when User then unfollow_user(obj)
    when Board then unfollow_board(obj)
    else nil
    end
  end
  
  def unfollow_user(obj)
    Rails.redis.srem(redis_name__following_users, obj.id)
    Rails.redis.srem(obj.redis_name__followed_by,   self.id)
  end

  def unfollow_board(obj)
    Rails.redis.srem(redis_name__following_boards,  obj.id)
    Rails.redis.srem(obj.redis_name__followed_by,     self.id)
  end

  # counters
  
  def following_even_indirectly_count
    Rails.redis.scard(redis_name__following_users)
  end
  
  def following_individual_boards_count
    Rails.redis.scard(redis_name__following_boards)
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
  
  def redis_name__followed_by
    "u:#{self.id}:followed_by"
  end
  
  def redis_name__following_users
    "u:#{self.id}:following:u"
  end

  def redis_name__following_boards
    "u:#{self.id}:following:b"
  end

  def redis_name__likes
    "u:#{self.id}:likes"
  end
  
  def redis_name__last_board
    "u:#{self.id}:last_board"
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
    User.where(:id => redis_name__following_users).find_each    {|u| unfollow(u) }
    Board.where(:id => redis_name__following_boards).find_each  {|b| unfollow(b) }
    directly_followed_by_ids.each {|u| u.unfollow(self) }
    likes.each {|l| unlike(l)}
    
    # Remove my redis objects
    Rails.redis.del(redis_name__categories)
    Rails.redis.del(redis_name__followed_by)
    Rails.redis.del(redis_name__following_users)
    Rails.redis.del(redis_name__following_boards)
    Rails.redis.del(redis_name__likes)
    Rails.redis.del(redis_name__last_board)
  end
  
end
