class ProfilesController < ApplicationController
  before_filter :get_profile
  
  def show
    redirect_to :action => 'boards'
  end
  
  def boards
    @boards = @profile.boards
  end
  
  protected
  
  def get_profile
    unless @profile = User.find_by_id(params[:id])
      redirect_to root_path, :notice => "Unable to find the specified profile"
    end
  end
end
