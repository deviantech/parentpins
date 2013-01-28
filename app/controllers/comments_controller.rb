class CommentsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create, :destroy]
  
  def create
    @comment = current_user.comments.new(params[:comment])
    
    if @comment.save
      flash[:notice] = "Added comment"
    else
      flash[:error] = "Unable to save comment"
    end
    redirect_to :back
  end
  
  def destroy
    current_user.comments.find_by_id(params[:id]).try(:destroy)
    render :nothing => true
  end
  
end
