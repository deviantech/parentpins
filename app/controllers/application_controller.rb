class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  
  private
  
  def maybe_ajax
    params[:via_ajax] ? false : true
  end
  
  # Devise: after user signs up, direct to activity page with the step 2 shown (note that after_sign_up_path_for wasn't working)
  def after_sign_in_path_for(resource)
    if resource.sign_in_count == 1
      activity_profile_path(resource, :step_2 => true)
    else
      root_path
    end
  end
  
end
