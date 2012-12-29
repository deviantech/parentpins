class PinsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
    
  def index
    # TODO: implement some sort of trending logic
    # TODO: include user or else cache username
    @pins = Pin.limit(20)
  end
  
end
