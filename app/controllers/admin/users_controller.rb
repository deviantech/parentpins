class Admin::UsersController < Admin::BaseController

  # FUTURE: this is a stub thrown together. Very inefficient. Limited functionality. 
  def index
    @users = User.order('id DESC').all
  end
  
end
