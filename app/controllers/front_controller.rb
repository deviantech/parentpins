class FrontController < ApplicationController
  caches_page :about, :legal, :privacy
  
  def contact
  end
  
  # remove email paths after roadie is configured
  def email_unlock_instructions
    render 'front/email_unlock_instructions', :layout => 'email'
  end
  def email_confirmation_instructions
    render 'front/email_confirmation_instructions', :layout => 'email'
  end
  def email_password_reset
    render 'front/email_password_reset', :layout => 'email'
  end
end
