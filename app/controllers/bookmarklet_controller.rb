class BookmarkletController < ApplicationController
  
  def pin
    unless user_signed_in?
      session[:user_return_to] = url_for(params)
      redirect_to(popup_login_path) and return 
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
    session[:popup_login] = true # On login error, redirect back here rather than normal sessions/new path
    render 'devise/sessions/new', :layout => 'bookmarklet'
  end
    
end
