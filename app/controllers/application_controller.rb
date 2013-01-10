class ApplicationController < ActionController::Base
  protect_from_forgery
  
  # Devise: after user signs up, direct to activity page with the step 2 shown
  def after_sign_up_path_for(resource)
    activity_profile_path(resource, :step_2 => true)
  end
  
end
