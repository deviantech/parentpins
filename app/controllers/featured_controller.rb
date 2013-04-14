class FeaturedController < ApplicationController
  before_filter :protect_actions, :only => [:create, :destroy]
  
  def index
  end
  
  def create
    @to_feature.try(:feature)
    render :nothing => true
  end
  
  def destroy
    @to_feature.try(:unfeature)
    render :nothing => true
  end
  
  protected

  def protect_actions
    @to_feature = current_user.try(:admin?) && User.find(params[:profile_id])
  end
  
end
