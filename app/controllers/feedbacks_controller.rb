class FeedbacksController < ApplicationController
  before_action :authenticate_user!
  before_action :make_feedback
  
  def new
  end
  
  def create
    if @feedback.save
      redirect_to '/', :success => "Thanks for the feedback!"
    else
      flash.now[:error] = "Unable to save feedback"
      render new
    end
  end
  
  protected
  
  def make_feedback
    @feedback = current_user.feedbacks.new(params[:feedback])
    @feedback.email = current_user.email if @feedback.email.blank?
    @feedback.user_agent = request.user_agent
  end
  
end
