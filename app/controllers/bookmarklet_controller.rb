class BookmarkletController < ApplicationController
  
  def new_pin
    unless user_signed_in?
      session[:bookmarklet_pin] = url_for(params)
      redirect_to(:action => 'login') and return 
    end
    
    # TODO - implement this, kinda like new but optimized for popup window
    @pin = Pin.from_bookmarklet(current_user, params)
  end
  
  def create
    @pin = Pin.from_bookmarklet(current_user, params)
    if @pin.update_attributes(params[:pin])
      
    else
      
    end
  end
  
  def login
    render :text => 'TODO: replace with a narrower login form'
  end
  
  protected
  
  
  
end
