class Feedback < ActiveRecord::Base
  belongs_to :user
  
  attr_accessible :body, :email, :user_agent, :user_id
  
  validates_presence_of :body, :email, :user_id
  
  after_create :notify_admins
  
  protected
  
  def notify_admins
    AdminMailer.new_feedback(self.id).deliver
  end
end
