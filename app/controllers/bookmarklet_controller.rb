class BookmarkletController < ApplicationController
  
  def pin
    unless user_signed_in?
      session[:bookmarklet_pin] = url_for(params)
      redirect_to(:action => 'login') and return 
    end
        
    @pin = params[:pin] ? Pin.new(params[:pin]) : Pin.from_bookmarklet(current_user, params)    
  end
  
  def create
    @pin = Pin.from_bookmarklet(current_user, params)
    if @pin.update_attributes(params[:pin])
      render :text => %Q{<script type="text/javascript" charset="utf-8">window.close();</script>}
    else
      render 'pin'
    end
  end
  
  def login
    render :text => 'TODO: replace with a narrower login form'
  end
  
  protected
  
  
  
end
