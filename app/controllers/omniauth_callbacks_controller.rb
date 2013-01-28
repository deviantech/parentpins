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

    if @user.persisted?
      sign_in @user, :event => :authentication # this will throw if @user is not activated
      @after_sign_in_url = after_sign_in_path_for(@user)
      set_flash_message(:notice, :success, :kind => kind) if is_navigational_format?
      render 'callback', :layout => false

    else
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end
  
end
