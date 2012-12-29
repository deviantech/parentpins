class PinsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
    
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
  end
  
end
