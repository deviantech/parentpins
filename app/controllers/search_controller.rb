class SearchController < ApplicationController
  before_action :set_kind_from_params

  def redirect_by_kind
    redirect_to "/search/#{@kind}?q=#{params[:q]}"
  end
  
  def index
    redirect_to(root_path, :error => 'You forgot to enter a search query.') and return if params[:q].blank?

    klass = @kind.capitalize.singularize.constantize
    @results = klass.search(params[:q]).page(params[:page])
    support_ajax_pagination
  end

  protected
  
  def set_kind_from_params
    @kind = %w(pins boards users).include?(params[:kind]) ? params[:kind] : 'pins'
  end
  
end
