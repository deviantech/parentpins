class Comment < ActiveRecord::Base
  default_scope { order('id DESC') }
  attr_accessible :body, :commentable_id, :commentable_type, :user_id
  
  belongs_to :user
  belongs_to :commentable,  :polymorphic => true, :counter_cache => true, :touch => true
  
  validates_presence_of :commentable, :user
  validates_length_of :body, :minimum => 1
  
  after_create :send_notification
  
  protected
  
  def send_notification
    UserMailer.comment_received(self.id)
  end
end
