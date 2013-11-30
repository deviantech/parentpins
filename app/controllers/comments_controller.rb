class CommentsController < ApplicationController
  before_action :authenticate_user!, :only => [:create, :destroy]
  
  def create
    @comment = current_user.comments.create(params[:comment])
    respond_to do |wants|
      wants.html { redirect_to :back }
      wants.js
    end
  end
  
  def destroy
    @comment = current_user.comments.where(:id => params[:id]).first
    @comment.try(:destroy)
  end
  
end
