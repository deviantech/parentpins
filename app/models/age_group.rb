class AgeGroup < ActiveRecord::Base
  has_many :pins
  attr_accessible :name
  
  validates_uniqueness_of :name, :allow_blank => false
  
  def self.all_cached
    Rails.cache.fetch('all_age_groups', :expires_in => 1.hour) do
      AgeGroup.all
    end
  end

end
