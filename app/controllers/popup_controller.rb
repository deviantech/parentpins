class PopupController < ApplicationController
  protect_from_forgery :except => [:pin]
  before_action :clean_params, :only => [:pin]
  
  def pin
    unless user_signed_in?
      session[:user_return_to_from_pin] = session[:user_return_to] = url_for(params)
      redirect_to(popup_login_path) and return 
    end
    
    @pin = params[:pin] ? Pin.craft_new_pin(current_user, params[:pin]) : Pin.new_from_bookmarklet(current_user, params)
  end
  
  def success
    @pin = Pin.first
  end
  
  def create
    session.delete(:user_return_to_from_pin) # Clean up session
    
    conditionally_remove_nested_attributes(:pin, :board)
    @pin = Pin.craft_new_pin(current_user, params[:pin])
    if @pin.save
      render 'success'
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
  def clean_params
    [:description, :title].each {|k| clean_encoding(params[k])}
    [:media, :link].each {|k| absolutize_param(k) }
  end
  
  def absolutize_param(key)
    return true if params[key].blank? || params[key].match(/^https?/i)
    return true if key == :media && params[key].match(/base64/i)
    
    params[key] = URI.join(URI.escape(params[:url]), URI.escape(params[key]))
  end

  # Prevent errors from "invalid byte sequence in UTF-8" coming from external sources
  def clean_encoding(str)
    if String.method_defined?(:encode) # Skip before Ruby 1.9
      str.encode!('UTF-16', 'UTF-8', :invalid => :replace, :replace => '')
      str.encode!('UTF-8', 'UTF-16')
    end
  end
  
end
