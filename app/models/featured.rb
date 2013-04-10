class Featured < ActiveRecord::Base
  attr_accessible :description, :user_id
  
  belongs_to :user
  
  after_create :notify_user
  before_update {|m| m.live = true} # Any subsequent edits should make it live
  
  scope :random, order('rand()')
  scope :with_user, includes(:user)
  scope :live, where(:live => true)
  
  def self.show(n = 2)
    live.random.with_user.limit(n)
  end
  
  
  protected
  
  
  def notify_user
    # TODO: email user to notify
  end
  # TODO - email user on create with link. when saved, become active. if admin deactivate, leave around but don't display. If admin add again later, just reactivate and jump to live status.
  
end
