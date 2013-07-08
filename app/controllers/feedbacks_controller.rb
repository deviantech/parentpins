class FeedbacksController < ApplicationController
  before_filter :authenticate_user!
  before_filter :make_feedback
  
  def new
  end
  
  def create
    if @feedback.save
      flash[:success] = "Thanks for the feedback!"
      redirect_to '/'
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
