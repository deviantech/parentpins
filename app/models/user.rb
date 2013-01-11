class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  mount_uploader :avatar,       AvatarUploader
  mount_uploader :cover_image,  CoverImageUploader
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :provider, :uid, :avatar, :interested_category_ids, :kids, :bio, :avatar_cache, :cover_image, :cover_image_cache
  
  has_many :boards,       :dependent => :destroy
  has_many :pins,         :dependent => :destroy
  has_many :pins_via_me,                            :class_name => 'Pin',   :foreign_key => 'via_id'
  has_many :pins_originally_from_me,                :class_name => 'Pin',   :foreign_key => 'originally_from_id'
  has_many :comments,     :dependent => :destroy
  
  has_many :feedbacks
  
  validates_numericality_of :kids, :allow_blank => true

  def interested_category_ids=(ids)
    Rails.redis.del(interested_category_set_name)
    add_interested_categories(ids)
  end

  def interested_category_ids
    Rails.redis.smembers(interested_category_set_name)
  end

  def interested_categories
    Category.where(:id => interested_category_ids)
  end
  
  def add_interested_categories(cats)
    Rails.redis.sadd(interested_category_set_name, cleaned_ids(cats))
  end
  
  def remove_interested_categories(cats)
    Rails.redis.srem(interested_category_set_name, cleaned_ids(cats))
  end
  
  def name
    username.to_s.titleize
  end
  

  # TODO: implement this
  def likes; pins.map(&:id); end
  def followers; User.all.map(&:id); end
  def following; User.all.map(&:id); end
  
  
  protected
  
  def interested_category_set_name
    "u:#{self.id}:categories"
  end
  
  def cleaned_ids(cats)
    Array(cats).select{|c| !c.blank?}.map{ |cat| cat.respond_to?(:id) ? cat.id : cat }.uniq
  end
  
end
