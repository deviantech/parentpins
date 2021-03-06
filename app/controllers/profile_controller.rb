class ProfileController < ApplicationController
  before_action :authenticate_user!,  :only => [:edit, :update, :activity, :remove_generic, :generic_crop]
  before_action :get_profile,         :except => [:got_bookmarklet, :remove_generic, :generic_crop]
  before_action :get_profile_owner,   :only => [:edit, :update, :activity]
  before_action :set_filters,         :only => [:pins, :likes, :activity]
  
  def show
    flash.keep
    redirect_to @profile == current_user ? activity_profile_path(@profile) : profile_boards_path(@profile)
  end
  
  def activity    
    paginate_pins @profile.activity
  end
  
  def pins
    if params[:context] == 'select-featured'
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
  
  # TODO: get_profile_owner is a clumbsy way of just using current_user and calling get_profile_counters.
  def update
    if params[:from] == 'step_2' ? @profile.update_attributes(params[:user]) : @profile.update_maybe_with_password(params[:user])
      sign_in(@profile, :bypass => true)
      msg = params[:from] == 'step_2' ? "We've started you out automatically following two of our featured users. Their pins will appear here on your Activity tab." : "Your profile changes have been saved."
      new_path = @profile.cover_image_was_changed ? crop_cover_image_path : (@profile.avatar_was_changed ? crop_avatar_path : activity_profile_path(@profile))
      redirect_to new_path, :success => msg
    else
      render 'edit'
    end
  end
  
  def generic_crop
    @profile = current_user
    get_profile_counters

    unless current_user.send("#{params[:which]}?")
      redirect_to(edit_profile_path(current_user), :error => "You must upload an image before trying to crop it.") and return
    end

    @dimensions = case params[:which]
    when :avatar      then [120, 120]
    when :cover_image then [160, 1020]
    else []
    end
        
    if request.post?
      current_user.update_attributes(params[:user])
      current_user.send(params[:which]).recreate_versions!
      redirect_to activity_profile_path(current_user) and return
    end
  end
    
  def remove_generic
    current_user.remove_cropped(params[:which])
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
    redirect_to root_path, :error => "Unable to find the specified profile."
  end
  
  def get_profile_owner
    unless @profile == current_user
      redirect_to(profile_path(@profile), :error => "You don't own this profile.") and return
    end
  end

end
