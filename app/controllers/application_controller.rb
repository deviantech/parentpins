class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :consider_ajax_layout
  
  
  
  private
  
  def set_pin_filters
    @kind = params[:kind] if Pin::VALID_TYPES.include?(params[:kind])
    
    cat_id = params[:category_id] || params[:category]
    @category = Category.find_by_id(cat_id) unless cat_id.blank?
    
    age_id = params[:age_group_id] || params[:age_group]
    @age_group = AgeGroup.find_by_id(age_id) unless age_id.blank?
  end
  
  def consider_ajax_layout
    # Returning false means no layout. Returning nil resets layout, and it will be set as usual by inheritance
    self.class.layout(params[:via] == 'ajax' ? false : nil)
  end
end
