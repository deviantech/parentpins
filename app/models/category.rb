class Category < ActiveRecord::Base
  has_many :boards
  has_many :pins
  attr_accessible :name
  
  validates_uniqueness_of :name, :allow_blank => false  
  
  default_scope { order('name ASC') }
  
  def self.all_cached
    Rails.cache.fetch('all_categories', :expires_in => 1.hour) do
      Category.all
    end
  end
end
