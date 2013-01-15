class SearchController < ApplicationController
  
  def index
    @kind = %w(pins boards users).include?(params[:kind]) ? params[:kind] : 'pins'
    klass = @kind.capitalize.singularize.constantize

    # TODO: eventually use sphinx or similar for indexing
    @results = klass.search(params[:q])
    # TODO - add pagination
  end
  
end
