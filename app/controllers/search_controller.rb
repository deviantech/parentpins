class SearchController < ApplicationController
  before_filter :set_kind_from_params

  def redirect_by_kind
    redirect_to "/search/#{@kind}"
  end
  
  def index
    klass = @kind.capitalize.singularize.constantize

    # TODO: eventually use sphinx or similar for indexing
    @results = klass.search(params[:q])
    # TODO - add pagination
  end

  protected
  
  def set_kind_from_params
    @kind = %w(pins boards users).include?(params[:kind]) ? params[:kind] : 'pins'
  end
  
end
