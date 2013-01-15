require 'searchable'
class Board < ActiveRecord::Base
  extend Searchable
  mount_uploader :cover, BoardCoverUploader

  belongs_to :user
  belongs_to :category
  belongs_to :age_group
  has_many :pins, :dependent => :destroy, :after_add => :set_cover_from_pin, :before_remove => :update_cover_before_pin_removed
  
  attr_protected :id
  
  validates_presence_of :user, :category, :age_group
  validates_length_of :name, :minimum => 2
  validates_uniqueness_of :name, :scope => :user_id
  
  scope :in_category, lambda {|cat|
    cat.blank? ? where('1=1') : where({:category_id => cat.id})
  }
  
  # TODO: cache these in redis or something, to prevent n+1 calls on board index pages?
  def thumbnails
    pins.order('id DESC').limit(4).collect{ |p| p.image.v55.url }
  end
  
  def set_cover_from_pin(pin)
    update_attribute :cover, pin.image.v320
  end
  
  def update_cover_before_pin_removed(pin)
    if next_pin = pins.with_image.order('id DESC').where(['id <> ?', pin.try(:id)]).first
      update_attribute :cover, next_pin.image.v320
    else
      update_attribute :remove_cover, true
    end
  end
end
