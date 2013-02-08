class ProfileController < ApplicationController
  before_filter :authenticate_user!,  :only => [:edit, :update, :activity]
  before_filter :get_profile
  before_filter :get_profile_owner,   :only => [:edit, :update, :activity]
  before_filter :set_filters,         :only => [:pins, :likes, :followed_by, :following]
  
  def show
    redirect_to @profile == current_user ? activity_profile_path(@profile) : profile_boards_path(@profile)
  end
  
  def activity    
    paginate_pins @profile.activity
  end
  
  def pins
    paginate_pins @profile_counters[:pins].zero? ? Pin.trending : @profile.pins
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
      redirect_to activity_profile_path(@profile), :notice => "Updated profile"
    else
      render 'edit'
    end
  end
    
  def follow
    current_user.follow(@profile) if user_signed_in?
  end
  
  def unfollow
    current_user.unfollow(@profile) if user_signed_in?
    render 'follow'
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
    redirect_to(root_path, :notice => "Unable to find the specified profile")
  end
  
  def get_profile_owner
    unless @profile == current_user
      redirect_to(profile_path(@profile), :notice => "You don't own this profile") and return
    end
  end

end
