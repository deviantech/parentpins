# https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def facebook
    oauthorize "Facebook"
  end
  
  def twitter
    oauthorize "Twitter"
  end
  
  def linked_in
    oauthorize "LinkedIn"
  end
    
  protected
  
      
  def oauthorize(kind)
    @user = User.find_for_oauth(request.env["omniauth.auth"], current_user)

    if @user.new_record?
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    else
      sign_in @user, :event => :authentication # this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => kind)
      redirect_to after_sign_in_path_for(@user)
    end
  end
  
end
