class FeaturedController < ApplicationController
  
  def index
    @featured = Featured.with_user.random.limit(4)
  end
  
end
