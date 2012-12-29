class PinsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
    
  def index
    # TODO: implement some sort of trending logic
    # TODO: include user or else cache username
    @kind = params[:kind] if Pin::VALID_TYPES.include?(params[:kind])
    @pins = Pin.by_kind(@kind).limit(20)
  end
  
end
