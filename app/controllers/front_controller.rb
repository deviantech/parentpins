class FrontController < ApplicationController
  # TODO: can't page cache, because different UI logged in vs. not
  # caches_page :legal, :privacy
  
  def contact
  end
  
  def bookmarklet
  end
  
  def login_first
    from = request.env["HTTP_REFERER"] ? :back : '/'

    if user_signed_in?
      redirect_to from
    else
      session[:user_return_to] = from
      redirect_to new_user_session_path, :error => "Please log in to continue."
    end
  end
  
end
