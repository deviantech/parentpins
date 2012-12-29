class PinsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index]
    
  def index
    # TODO: implement some sort of trending logic
    # TODO: include user or else cache username
    @kind = params[:kind] if Pin::VALID_TYPES.include?(params[:kind])
    @pins = Pin.by_kind(@kind).limit(20)
  end
  
  def new
    if current_user.boards.empty?
      redirect_to(new_board_path, :notice => 'Please add a board first!') and return
    end
    @pin = current_user.pins.new(params[:pin])
  end
  
  def create
    @pin = current_user.pins.new(params[:pin])
    if @pin.save
      redirect_to @pin.board, :notice => 'Added new pin'
    else
      flash.now[:error] = "Unable to save pin"
      render :action => 'new'
    end    
  end
  
  def edit
    @pin = current_user.pins.find(params[:id])
    render :action => 'new'
  end
  
  def update
    @pin = current_user.pins.find(params[:id])
    if @pin.update_attributes(params[:pin])
      redirect_to @pin.board, :notice => 'Saved changes to pin'
    else
      flash.now[:error] = "Unable to save pin"
      render :action => 'new'
    end
  end
  
  def destroy
    # TODO - implement me
  end
  
end
