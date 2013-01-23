# For bookmarklet/popup logins, redirect to that login page instead of main site login.
# https://github.com/plataformatec/devise/wiki/How-To%3a-Redirect-to-a-specific-page-when-the-user-can-not-be-authenticated
class CustomLoginFailure < Devise::FailureApp
  def redirect_url
    if session[:popup_login]
      popup_login_path
    else
      super
    end
  end

  # You need to override respond to eliminate recall
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
