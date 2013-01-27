class Board < ActiveRecord::Base
  extend Searchable
  mount_uploader :cover, BoardCoverUploader

  belongs_to :user
  belongs_to :category
  has_many :pins, :dependent => :destroy, :after_add => :set_cover_from_pin, :before_remove => :update_cover_before_pin_removed, :inverse_of => :board
  
  attr_protected :id, :created_at, :updated_at, :slug

  extend FriendlyId
  friendly_id :name, :use => [:slugged, :scoped], :scope => :user
  
  validates_presence_of :user, :category, :slug
  validates_length_of :name, :minimum => 2
  validates_uniqueness_of :name, :scope => :user_id
  
  after_save :update_pin_settings
  
  scope :in_category, lambda {|cat|
    cat.blank? ? where('1=1') : where({:category_id => cat.id})
  }
  scope :newest_first, order('id DESC')
  
  def self.trending
    # TODO: implement some sort of trending logic
    newest_first
  end
  
  # TODO: cache these in redis or something, to prevent n+1 calls on board index pages?
  def thumbnails
    pins.newest_first.limit(4).collect{ |p| p.image.v55.url }
  end
  
  def set_cover_from_pin(pin)
    update_attribute :cover, pin.image
  end
  
  def update_cover_before_pin_removed(pin)
    if next_pin = pins.with_image.newest_first.where(['id <> ?', pin.try(:id)]).first
      update_attribute :cover, next_pin.image
    else
      update_attribute :remove_cover, true
    end
  end

  protected
  
  def update_pin_settings
    return true unless category_id_changed?
    
    pins.find_each do |pin|
      pin.send(:copy_board_settings)
      pin.save
    end
  end
    
end
