class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  mount_uploader :avatar,       AvatarUploader
  mount_uploader :cover_image,  CoverImageUploader
  
  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :provider, :uid, :avatar
  
  has_many :boards,       :dependent => :destroy
  has_many :pins,         :dependent => :destroy
  has_many :pins_via_me,                            :class_name => 'Pin',   :foreign_key => 'via_id'
  has_many :pins_originally_from_me,                :class_name => 'Pin',   :foreign_key => 'originally_from_id'
  has_many :comments,     :dependent => :destroy
  
  
  def name
    username.to_s.titleize
  end
end
