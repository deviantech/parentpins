class ProfilesController < ApplicationController
  before_filter :get_profile
  before_filter :authenticate_user!,  :only => [:edit, :update, :activity]
  before_filter :get_profile_owner,   :only => [:edit, :update, :activity]
  
  def show
    redirect_to :action => 'boards'
  end
  
  def activity    
    if params[:add] && to_add = Category.find_by_id(params[:add])
      current_user.add_interested_categories(to_add)
    end
    
    if params[:remove] && to_remove = Category.find_by_id(params[:remove])
      current_user.remove_interested_categories(to_remove)
    end
    
    @pins = Pin.in_categories(current_user.interested_categories).limit(20)
    # TODO: add pagination
  end
  
  def pins
    # TODO: add better logic for picking popular vs new pins
    @pins = @profile_counters[:pins].zero? ? Pin.limit(20) : @profile.pins
  end
  
  def likes
    @pins = Pin.where(:id => @profile.likes).limit(20)
    # TODO: add pagination
  end
  
  def followers
    @followers = [] # TODO: implement followers
    @pins = Pin.pinned_by(@followers).limit(20)
    # TODO: add pagination
  end
  
  def following
    @following = [] # TODO: implement following
    @pins = Pin.pinned_by(@following).limit(20)
    # TODO: add pagination
  end
  
  def boards
    @boards = @profile.boards
  end
  
  def board
    unless @board = @profile.boards.find_by_id(params[:id])
      redirect_to :action => 'show', :notice => "Unable to find the specified board"
    end
    @pins = @board.pins.limit(20) # TODO: add pagination
  end
  
  
  
  def edit
  end
  
  def update
    if @profile.update_attributes(params[:user])
      redirect_to activity_profile_path(@profile), :notice => "Updated profile"
    else
      if params[:step_2]
        activity
        render 'activity'
      else
        render 'edit'
      end
    end
  end
  
  protected
  
  def get_profile
    unless @profile = User.find_by_id(params[:id])
      redirect_to(root_path, :notice => "Unable to find the specified profile") and return
    end
    
    @profile_counters = {
      :pins       => @profile.pins.count,
      :boards     => @profile.boards.count,
      :likes      => @profile.likes.count,
      :followers  => @profile.followers.count,
      :following   => @profile.following.count
    }
  end
  
  def get_profile_owner
    unless @profile == current_user
      redirect_to(profile_path(@profile), :notice => "You don't own this profile") and return
    end
  end
end
