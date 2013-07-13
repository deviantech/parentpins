class FeaturedController < ApplicationController
  before_filter :authenticate_user!,    :only => [:create, :destroy]
  before_filter :ensure_profile_owner,  :only => [:set_pin]
  
  def index
  end
  
  def create
    profile = User.find(params[:profile_id])
    profile.feature if profile && current_user.admin?
    render :nothing => true
  end
  
  def destroy
    profile = User.find(params[:profile_id])
    profile.unfeature if profile && (current_user.admin? || current_user == profile)
    render :nothing => true
  end
  
  def set_pin
    @profile.update_attribute(:featured_pin_id, @profile.pins.find(params[:id]).id)
    flash[:success] = "Updated featured pin."
    redirect_to edit_profile_path(@profile)
  end
  
  protected

  def ensure_profile_owner
    @profile = User.find(params[:profile_id])
    unless user_signed_in? && @profile == current_user
      flash[:error] = "You don't own this profile."
      redirect_to(profile_path(@profile)) and return
    end
  end
  
end
