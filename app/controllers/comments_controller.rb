class CommentsController < ApplicationController
  before_filter :authenticate_user!, :only => [:create, :destroy]
  
  def create
    @comment = current_user.comments.create(params[:comment])
    respond_to do |wants|
      wants.html { redirect_to :back }
      wants.js
    end
  end
  
  def destroy
    @comment = current_user.comments.find_by_id(params[:id])
    @comment.try(:destroy)
  end
  
end
