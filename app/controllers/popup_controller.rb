class PopupController < ApplicationController
  protect_from_forgery :except => [:pin]
  before_filter :absolutize_params, :only => [:pin]
  
  def pin
    unless user_signed_in?
      session[:user_return_to_from_pin] = session[:user_return_to] = url_for(params)
      redirect_to(popup_login_path) and return 
    end

    @pin = params[:pin] ? Pin.new(params[:pin]) : Pin.from_bookmarklet(current_user, params)
  end
  
  def create
    session.delete(:user_return_to_from_pin) # Clean up session
    conditionally_remove_nested_attributes(:pin, :board)
    @pin = current_user.pins.new(params[:pin])
    if @pin.save
      render :text => %Q{<script type="text/javascript" charset="utf-8">window.close();</script>}
    else
      render 'pin'
    end
  end
  
  def login
    if user_signed_in?
      redirect_to session.delete(:user_return_to_from_pin) and return
    end
    session[:popup_login] = true # On login error, redirect back here rather than normal sessions/new path
    render 'devise/sessions/new', :layout => 'popup'
  end


  protected
  
  # Handle receiving local links from bookmarklet
  def absolutize_params
    [:media, :link].each {|k| absolutize_param(k) }
  end
  
  def absolutize_param(key)
    return true if params[key].blank? || params[key].match(/^https?/i)
    return true if key == :media && params[key].match(/base64/i)
    
    params[key] = URI.join(URI.escape(params[:url]), URI.escape(params[key]))
  end

end
