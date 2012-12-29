class ProfilesController < ApplicationController
  before_filter :get_profile
  
  def show
    redirect_to :action => 'boards'
  end
  
  def activity
  end
  
  def pins
    # TODO: add better logic for picking popular vs new pins
    @pins = @profile_counters[:pins].zero? ? Pin.limit(20) : @profile.pins
  end
  
  def likes
  end
  
  def followers
  end
  
  def following
  end
  
  def boards
    @boards = @profile.boards
  end
  
  def board
    unless @board = @profile.boards.find_by_id(params[:id])
      redirect_to :action => 'show', :notice => "Unable to find the specified board"
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
      :likes      => 3,
      :followers  => 0,
      :following   => 12
    }
  end
end
