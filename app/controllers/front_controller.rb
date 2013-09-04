class FrontController < ApplicationController
  # TODO: can't page cache, because different UI logged in vs. not
  # caches_page :legal, :privacy
  
  def contact
  end
  
  def bookmarklet
  end
  
  def login_first
    if user_signed_in?
      redirect_to request.env["HTTP_REFERER"] ? :back : '/'
    else
      session[:user_return_to] = request.referer
      flash[:error] = "Please log in to continue."
      redirect_to new_user_session_path
    end
  end
  
end
