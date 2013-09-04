class PinsController < ApplicationController
  before_filter :authenticate_user!,      :except => [:index, :show]
  before_filter :find_current_users_pin,  :only => [:edit, :update, :destroy, :success]
  before_filter :find_any_pin,            :only => [:like, :unlike]
  before_filter :set_filters,             :only => [:index]
  respond_to :html, :js
  
  def index
    debugger
    paginate_pins Pin.includes(:user).trending
  end
  
  # New or, if source_id passed, repin
  def new
    @pin, @source = Pin.craft_new_pin(current_user, params[:pin], params[:source_id], :skip_board => true)
  end
  
  def create
    conditionally_remove_nested_attributes(:pin, :board)
    @pin, @source = Pin.craft_new_pin(current_user, params[:pin], params[:source_id])
    @pin.save
    success_url = (@pin.board && !@pin.board.new_record?) ? profile_board_path(current_user, @pin.board) : '/'
    respond_with @pin, :location => success_url
  end
  
  # Shown after successful repin
  def success
  end
  
  def show
    @pin = Pin.includes([:user, :comments]).find(params[:id])
  end
    
  def edit
    render :action => 'new'
  end
  
  def update
    conditionally_remove_nested_attributes(:pin, :board)
    if @pin.update_attributes(params[:pin])
      redirect_to profile_board_path(current_user, @pin.board)
    else
      flash.now[:error] = "Unable to save pin"
      render :action => 'new'
    end
  end
  
  def destroy
    redirect_to profile_board_path(current_user, @pin.board)
    @pin.destroy
  end
    
  def like
    current_user.like(@pin)
  end
  
  def unlike
    current_user.unlike(@pin)
    render 'like'
  end
    
  protected
  
  def find_any_pin
    @pin = Pin.find(params[:id])
  end
  
  def find_current_users_pin
    @pin = current_user.pins.find(params[:id])
  end
  
end
