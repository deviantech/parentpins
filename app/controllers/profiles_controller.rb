class ProfilesController < ApplicationController
  before_filter :authenticate_user!,  :only => [:edit, :update, :activity, :account]
  before_filter :set_profile,         :only => [:account]
  before_filter :get_profile
  before_filter :get_profile_owner,   :only => [:edit, :update, :activity]
  before_filter :set_filters,         :only => [:pins, :likes, :followers, :following, :board, :boards]
  
  def show
    redirect_to :action => @profile == current_user ? 'activity' : 'boards'
  end
  
  def activity    
    paginate_pins @profile_counters[:following].zero? ? Pin.trending.in_category(current_user.interested_categories) : Pin.pinned_by(@following)
  end
  
  def pins
    paginate_pins @profile_counters[:pins].zero? ? Pin.trending : @profile.pins
  end
  
  def likes
    paginate_pins Pin.where(:id => @profile.likes)
  end
  
  def followers
    @followers = @profile.followers
  end
  
  def following
    @following = @profile.following
  end
  
  def boards
    paginate_boards @profile.boards
  end
  
  def board
    unless @board = @profile.boards.find_by_id(params[:board_id])
      redirect_to(boards_profile_path(@profile), :notice => "Unable to find the specified board") and return
    end
    paginate_pins @board.pins
  end
  
  def edit
  end
  
  def update
    params[:from] = 'edit' unless %w(edit account).include?(params[:from])
    if params[:from] == 'account' ? @profile.update_with_password(params[:user]) : @profile.update_attributes(params[:user])
      redirect_to activity_profile_path(@profile), :notice => "Updated profile"
    else
      if params[:step_2]
        activity
        render 'activity'
      else
        render params[:from]
      end
    end
  end
  
  def account
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
    if params[:id] == 'account' && params[:action] == 'show' # redirect from devise's user editing
      redirect_to account_profile_path(current_user) and return
    end
    
    unless @profile ||= User.find_by_id(params[:id])
      redirect_to(root_path, :notice => "Unable to find the specified profile") and return
    end
    
    @profile_counters = {
      :pins       => @profile.pins.count,
      :boards     => @profile.boards.count,
      :likes      => @profile.likes_count,
      :followers  => @profile.followers_count,
      :following   => @profile.following_count
    }
  end
  
  def get_profile_owner
    unless @profile == current_user
      redirect_to(profile_path(@profile), :notice => "You don't own this profile") and return
    end
  end

  def set_profile
    @profile = current_user
  end
end
