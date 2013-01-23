module PopupHelper
  
  # Allow re-using devise forms: https://github.com/plataformatec/devise/wiki/How-To:-Display-a-custom-sign_in-form-anywhere-in-your-app
  def resource_name
    :user
  end
 
  def resource
    @resource ||= User.new
  end
 
 def resource_class
   User
 end
 
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
  
end
