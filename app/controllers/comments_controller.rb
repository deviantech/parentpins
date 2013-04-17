class CommentsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create, :destroy]
  
  def create
    @comment = current_user.comments.new(params[:comment])
    
    unless @comment.save
      flash[:error] = "Unable to save comment."
    end

    redirect_to :back
  end
  
  def destroy
    @comment = current_user.comments.find_by_id(params[:id])
    @comment.try(:destroy)
  end
  
end
