class FeaturedController < ApplicationController
  before_filter :protect_actions,       :only => [:create, :destroy]
  before_filter :ensure_profile_owner,  :only => [:set_pin]
  
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
  
  def set_pin
    @profile.update_attribute(:featured_pin_id, @profile.pins.find(params[:id]).id)
    flash[:success] = "Updated featured pin."
    redirect_to edit_profile_path(@profile)
  end
  
  protected

  def protect_actions
    @to_feature = current_user.try(:admin?) && User.find(params[:profile_id])
  end

  def ensure_profile_owner
    @profile = User.find(params[:profile_id])
    unless user_signed_in? && @profile == current_user
      redirect_to(profile_path(@profile), :notice => "You don't own this profile.") and return
    end
  end
  
end
