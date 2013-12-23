class Admin::BaseController < ApplicationController
  before_action :require_admin
  
  protected
  
  def require_admin
    return if current_user.try(:admin?)
    redirect_to '/', :error => "You must be logged in as an admin to access that resource"
  end
end
