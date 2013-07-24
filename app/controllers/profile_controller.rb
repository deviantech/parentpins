class ProfileController < ApplicationController
  before_filter :authenticate_user!,  :only => [:edit, :update, :activity, :remove_cover_image, :remove_avatar]
  before_filter :get_profile,         :except => [:got_bookmarklet, :remove_cover_image, :remove_avatar]
  before_filter :get_profile_owner,   :only => [:edit, :update, :activity]
  before_filter :set_filters,         :only => [:pins, :likes, :activity]
  
  def show
    flash.keep
    redirect_to @profile == current_user ? activity_profile_path(@profile) : profile_boards_path(@profile)
  end
  
  def activity    
    paginate_pins @profile.activity
  end
  
  def pins
    if params[:context] == 'select_featured'
      flash.now[:info] = "Select a new Featured Pin."
    end
    paginate_pins @profile.pins
  end
  
  def likes
    paginate_pins Pin.where(:id => @profile.likes)
  end
  
  def followed_by
  end
  
  def following
  end
    
  def edit
  end
  
  def update
    if params[:from] == 'step_2' ? @profile.update_attributes(params[:user]) : @profile.update_maybe_with_password(params[:user])
      sign_in(@profile, :bypass => true)
      flash[:success] = "Your profile changes have been saved."
      redirect_to activity_profile_path(@profile)
    else
      render 'edit'
    end
  end
  
  def remove_cover_image
    current_user.update_attribute :remove_cover_image, 1
    redirect_to edit_profile_path(current_user)
  end

  def remove_avatar
    current_user.update_attribute :remove_avatar, 1
    redirect_to edit_profile_path(current_user)
  end
  
  def follow
    current_user.follow(@profile) if user_signed_in?
  end
  
  def unfollow
    current_user.unfollow(@profile) if user_signed_in?
    render 'follow'
  end
  
  def got_bookmarklet
    current_user.update_attribute(:got_bookmarklet, true) if user_signed_in?
    render(:nothing => true)
  end
  
  protected
  
  def get_profile
    if params[:id] == 'edit' && params[:action] == 'show' # redirect from devise's user editing
      authenticate_user!
      redirect_to edit_profile_path(current_user) and return
    end
    
    @profile ||= User.find(params[:id])
    get_profile_counters
  rescue ActiveRecord::RecordNotFound => e
    flash[:error] = "Unable to find the specified profile."
    redirect_to(root_path)
  end
  
  def get_profile_owner
    unless @profile == current_user
      flash[:error] = "You don't own this profile."
      redirect_to(profile_path(@profile)) and return
    end
  end

end
