class User < ActiveRecord::Base
  extend Searchable
  # Include default devise modules. Others available are:
  # :confirmable, :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable, :lockable

  mount_uploader :avatar,       AvatarUploader
  mount_uploader :cover_image,  CoverImageUploader
  include UploaderHelpers # Goes after uploaders mounted

  
  # Users with lower IDs are test users, and can be messed with as much as desired
  HIGHEST_TEST_USER_ID = 19
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :provider, :uid, :avatar, :kids, :bio, :avatar_cache, :cover_image, :cover_image_cache, :current_password, :teacher, :teacher_grade, :teacher_subject, :website, :featured_bio, :twitter_account, :facebook_account, :remove_cover_image, :cover_image_x, :cover_image_y, :cover_image_w, :cover_image_h, :remove_avatar, :avatar_x, :avatar_y, :avatar_w, :avatar_h, :email_on_comment_received, :email_on_new_follower, :name
  
  attr_accessor :cover_image_was_changed, :avatar_was_changed
  
  has_many :boards, -> { order('position ASC') },     :dependent => :destroy
  has_many :pins,         :dependent => :destroy
  has_many :imports,      :dependent => :destroy
  has_many :pins_via_me,                            :class_name => 'Pin',   :foreign_key => 'via_id'
  has_many :pins_originally_from_me,                :class_name => 'Pin',   :foreign_key => 'originally_from_id'
  has_many :comments,     :dependent => :destroy
  
  has_many :feedbacks
  
  extend FriendlyId
  friendly_id :username
  
  validates_uniqueness_of   :username,      :allow_blank => false
  validates_format_of       :username,      :with => /\A[a-z0-9\.\-\_]+\z/i
  validates_length_of       :username,      :minimum => 3, :maximum => 40
  validates_length_of       :name,          :maximum => 40
  validates_length_of       :email,         :maximum => 255
  validates_numericality_of :kids,          :allow_blank => true, :message => 'must be a number'
  validates_format_of       :website,       :allow_blank => true, :with => URI::regexp(%w(http https))
  validates_length_of       :bio,           :maximum => 400
  validates_length_of       :featured_bio,  :maximum => 400, :if => :featured?
  
  validate                  :valid_username, :valid_social_media_links
  before_save     :track_media_changes
  after_save      :touch_pins_if_necessary
  before_destroy  :clean_redis
  after_create    :prepopulate_following_users, :notify_admins

  # Used by searchable
  scope :newest_first,  -> { order('id DESC') }
  scope :featured,      -> { where(:featured => true) }

  def self.test_users
    User.where("id <= #{HIGHEST_TEST_USER_ID}")
  end

  def name
    self['name'].blank? ? username.to_s : self['name']
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
        user.username = data["username"] if user.username.blank?
        user.valid?
      end
    end
  end
  
  def self.find_for_oauth(auth, signed_in_resource = nil)
    user = signed_in_resource
    user ||= User.where(:provider => auth.provider, :uid => auth.uid).first
    user ||= (auth.info.email.blank? ? nil : User.where(:email => auth.info.email).first)
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

  def remove_cropped(which)
    return nil unless [:avatar, :cover_image].include?(which.to_sym)
    attribs = {"remove_#{which}" => 1, "#{which}_x" => nil, "#{which}_y" => nil, "#{which}_w" => nil, "#{which}_h" => nil}
    update_attributes(attribs)
  end

  def self.get_featured(n = 2)
    self.featured.order('rand()').limit(n)
  end

  def featured_bio
    desc = self['featured_bio']
    desc = self.bio if desc.blank?
    desc = 'No bio provided.' if desc.blank?
    desc
  end

  def feature
    return nil if featured?
    update_attribute :featured, true
    UserMailer.featured_notice(self.id).deliver if featured_pin_id.blank?     # Never clear featured_pin_id once set, so we can prevent sending emails if feature/unfeature/feature again
    update_attribute(:featured_pin_id, pins.first.id || 0) if featured_pin_id.blank? || !pins.exists?(featured_pin_id)  # Only update featured pin if there isn't a valid one set already
  end
  
  def unfeature
    update_attribute :featured, false
  end

  def featured_pin
    @featured_pin ||= (featured_pin_id.blank? || !pins.exists?(featured_pin_id)) ? pins.last : pins.find(featured_pin_id)
  end
  

  def twitter_account=(str)
    if str.blank?
      self['twitter_account'] = nil
      return
    end
    
    val = str.gsub(/@/, '').split('/').last.split('?').first
    if val.blank? 
      @twitter_error = str
    else
      self['twitter_account'] = val
    end
  end
  
  def twitter_account_url
    twitter_account.blank? ? nil : "https://twitter.com/#{twitter_account}"
  end
  
  def facebook_account=(str)
    return if str.blank?
    val = str.split('/').last.split('?').first
    if val.blank? 
      @facebook_error = str
    else
      self['facebook_account'] = val
    end
  end

  def facebook_account_url
    facebook_account.blank? ? nil : "https://www.facebook.com/#{facebook_account}"
  end
  
  # We track previously-imported (for pinterest imports) based on the URL the pins is referencing and the name of the original image (source_image_url)
  # Before returning, though, extract the CDN subdomain from the image URL (javascript takes this into account in step_1.js.coffee)
  def previously_imported_json
    Array(pins).each_with_object({}) {|p, result|
      next if p.source_image_url.blank? || !p.source_image_url.match(/\.pinimg.com/)
      result[p.url] ||= []
      result[p.url] << p.source_image_url.sub(/\Ahttps?:\/\//i, '//').sub(/\/\/.*?\.pinimg/i, '//*.pinimg')
    }.to_json
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
    uids = users_following_ids
    uids += Board.where(:id => boards_following_ids).select('DISTINCT(user_id)').map(&:user_id)
    User.where(:id => uids.uniq)
  end

  def following_even_indirectly_count
    following_even_indirectly.count
  end

  def followed_by_even_indirectly
    uids = followed_by_ids
    boards.each do |b| 
      uids += b.directly_followed_by_ids
    end
    User.where(:id => uids.flatten.uniq)
  end

  def followed_by_even_indirectly_count
    followed_by_even_indirectly.count
  end
  
  def direct_followers
    User.where(:id => followed_by_ids)
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
    user = User.where(:id => user).first unless user.is_a?(User)
    return nil if user.blank? || user.id == self.id
    
    Rails.redis.sismember(redis_name__followed_by, user.id)
  end
  
  def follow(obj)
    return nil if obj.blank? ||
      (obj.is_a?(User) && obj.id == self.id) ||
      (obj.is_a?(Board) && self.boards.include?(obj))
    
    case obj
    when User then follow_user(obj)
    when Board then follow_board(obj, true)
    else nil
    end
  end
    
  def follow_user(obj)
    Rails.redis.sadd(redis_name__following_users,   obj.id)
    Rails.redis.sadd(obj.redis_name__followed_by,   self.id)
    obj.boards.each do |board|
      follow_board(board)
    end
    UserMailer.followed(obj.id, self.id).deliver
  end
  
  def follow_board(obj, only_board = nil)
    Rails.redis.sadd(redis_name__following_boards,    obj.id)
    Rails.redis.sadd(obj.redis_name__followed_by,     self.id)
    UserMailer.followed(obj.user_id, self.id, obj.id).deliver if only_board
    true
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
    Rails.redis.srem(obj.redis_name__followed_by, self.id)
    obj.boards.each do |board|
      unfollow_board(board)
    end
  end

  def unfollow_board(obj)
    Rails.redis.srem(redis_name__following_boards,  obj.id)
    Rails.redis.srem(obj.redis_name__followed_by,   self.id)
  end

  # counters
    
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
    pin.touch
  end
  
  def unlike(pin)
    pin = pin.is_a?(Pin) ? pin : Pin.find(pin)

    Rails.redis.srem(redis_name__likes, pin.id)
    Rails.redis.srem(pin.redis_name__liked_by, self.id)    
    pin.touch
  end
  
  # ======================
  # = REDIS: queue names =
  # ======================    
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
  
  # Touch pins to reset cache on changes to avatar
  def touch_pins_if_necessary
    return true unless %w(avatar avatar_x avatar_y avatar_w avatar_h username).any? {|attrib| changes[attrib]}
    pins.map(&:touch)
  end

  
  
  
  # New users should start by following two random featured users, so their activity area isn't blank to start with
  def prepopulate_following_users
    User.get_featured(2).each do |f|
      follow_user(f)
    end
  end
  
  def notify_admins # TODO: do a daily batch email, so user has time to add bio information, etc.
    AdminMailer.new_user(self.id).deliver
  end
  
  def valid_social_media_links
    errors.add(:twitter_account, "doesn't appear valid") if @twitter_error
    errors.add(:facebook_account, "doesn't appear valid") if @facebook_error
  end
  
  def valid_username
    return if username.blank?
    errors.add(:username, 'cannot start with a number') if username.match(/\A\d/)
  end
  
  def track_media_changes
    @cover_image_was_changed = cover_image_changed?
    @avatar_was_changed = avatar_changed?
    return true
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
    Rails.redis.del(redis_name__followed_by)
    Rails.redis.del(redis_name__following_users)
    Rails.redis.del(redis_name__following_boards)
    Rails.redis.del(redis_name__likes)
    Rails.redis.del(redis_name__last_board)
  end
  
end
