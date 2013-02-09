class FrontController < ApplicationController
  caches_page :about, :legal, :privacy
  
  def contact
  end  
end
