class FrontController < ApplicationController
  caches_page :about, :legal, :privacy
  
  def contact
  end
  
  def login_first
    if user_signed_in?
      redirect_to :back
    else
      session[:user_return_to] = request.referer
      flash[:error] = "Please log in to continue."
      redirect_to new_user_session_path
    end
  end
  
end
