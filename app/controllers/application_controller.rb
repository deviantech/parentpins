class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :consider_ajax_layout
  
  
  
  private
  
  def consider_ajax_layout
    # Returning false means no layout. Returning nil resets layout, and it will be set as usual by inheritance
    self.class.layout(params[:via] == 'ajax' ? false : nil)
  end
end
