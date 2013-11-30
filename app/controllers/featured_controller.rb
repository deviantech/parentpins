class FeaturedController < ApplicationController
  before_action :authenticate_user!,    :only => [:create, :destroy]
  before_action :ensure_profile_owner,  :only => [:set_pin]
  
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
    if request.xhr?
      render :nothing => true
    else # User unfeaturing themselves from form isn't via ajax
      redirect_to :back
    end
  end
  
  def set_pin
    @profile.update_attribute(:featured_pin_id, @profile.pins.find(params[:id]).id)
    redirect_to edit_profile_path(@profile), :success => "Updated featured pin."
  end
  
  protected

  def ensure_profile_owner
    @profile = User.find(params[:profile_id])
    unless user_signed_in? && @profile == current_user
      redirect_to(profile_path(@profile), :error => "You don't own this profile.") and return
    end
  end
  
end
