class ProfilesController < ApplicationController
  before_filter :get_profile
  before_filter :authenticate_user!, :only => [:edit, :update]
  before_filter :get_profile_owner, :only => [:edit, :update]
  
  def show
    redirect_to :action => 'boards'
  end
  
  def activity
    # TODO: add pagination
    @pin_style = :narrow  # TODO: ugly to have this toggle in the controller...
    @pins = @profile.pins.limit(20)
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
  end
  
  protected
  
  def get_profile
    unless @profile = User.find_by_id(params[:id])
      redirect_to(root_path, :notice => "Unable to find the specified profile") and return
    end
    
    @profile_counters = {
      :pins       => @profile.pins.count,
      :boards     => @profile.boards.count,
      :likes      => 3,
      :followers  => 0,
      :following   => 12
    }
  end
  
  def get_profile_owner
    unless @profile == current_user
      redirect_to(profile_path(@profile), :notice => "You don't own this profile") and return
    end
  end
end
