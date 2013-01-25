class PopupController < ApplicationController
  protect_from_forgery :except => [:pin]
  before_filter :process_base64_urls, :only => [:pin]
  
  def pin
    unless user_signed_in?
      session[:user_return_to] = url_for(params)
      redirect_to(popup_login_path) and return 
    end
    
    @pin = params[:pin] ? Pin.new(params[:pin]) : Pin.from_bookmarklet(current_user, params)
  end
  
  def create
    conditionally_remove_nested_attributes(:pin, :board)
    @pin = Pin.from_bookmarklet(current_user, params)
    if @pin.update_attributes(params[:pin])
      render :text => %Q{<script type="text/javascript" charset="utf-8">window.close();</script>}
    else
      render 'pin'
    end
  end
  
  def login
    session[:popup_login] = true # On login error, redirect back here rather than normal sessions/new path
    render 'devise/sessions/new', :layout => 'popup'
  end

  protected
  
  def process_base64_urls
    return true if params[:media].blank? || !params[:media].match(/base64[;:,]/)
    
    tempfile = Tempfile.new("base64file")
    tempfile.binmode
    tempfile.write( Base64.decode64(params[:media]) )
    fname = SecureRandom.hex(16)
    uploaded_file = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :filename => fname, :original_filename => fname)
    params[:media] = uploaded_file
  end

end
