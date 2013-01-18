class PinsController < ApplicationController
  before_filter :authenticate_user!,      :except => [:index, :show]
  before_filter :find_current_users_pin,  :only => [:edit, :update, :destroy]
  before_filter :find_any_pin,            :only => [:show, :add_comment, :like, :unlike]
  before_filter :set_filters,             :only => [:index]
    
  def index
    # TODO: implement some sort of trending logic if kind/category aren't provided
    # TODO: include user or else cache username
    @pins = Pin.by_kind(@kind).in_category(@category).in_age_group(@age_group).page(params[:page])
    paginate_pins
  end
  
  def new
    if current_user.boards.empty?
      session[:post_board_url] = url_for(params.merge(:via => nil))
      redirect_to(new_board_path(:via => params[:via]), :notice => 'Please add a board first!') and return
    end
    
    # If a source ID is passed, allow repining
    @source, @pin = Pin.craft_new_pin(current_user, params[:source_id], params[:pin])
  end
  
  def create
    @source, @pin = Pin.craft_new_pin(current_user, params[:source_id], params[:pin])
    if @pin.save
      redirect_to board_profile_path(current_user, @pin.board), :notice => 'Added new pin'
    else
      flash.now[:error] = "Unable to save pin"
      render :action => 'new'
    end    
  end
  
  def show
  end
    
  def edit
    render :action => 'new'
  end
  
  def update
    if @pin.update_attributes(params[:pin])
      redirect_to @pin.board, :notice => 'Saved changes to pin'
    else
      flash.now[:error] = "Unable to save pin"
      render :action => 'new'
    end
  end
  
  def destroy
    redirect_to board_profile_path(current_user, @pin.board), :notice => 'Removed Pin'
    @pin.destroy
  end
  
  def add_comment
    if @comment.save
      flash[:notice] = "Added comment"
    else
      flash[:error] = "Unable to save comment"
    end
    redirect_to :back
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
    @comment = current_user.comments.new(params[:comment])
    @comment.pin = @pin # Don't use pin.comments.new, because then empty comment shows up when viewing pin.comments
  end
  
  def find_current_users_pin
    @pin = current_user.pins.find(params[:id])
  end
  
end
