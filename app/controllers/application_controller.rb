class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :consider_ajax_layout
  
  
  
  private

  def paginate_pins(base_scope)
    @results = @pins = base_scope.by_kind(@kind).in_category(@category).in_age_group(@age_group).page(params[:page])
    respond_to do |format|
      format.html {}
      format.pagination { render('shared/pagination', :formats => :html, :layout => false) }
    end
  end

  def paginate_boards(base_scope)
    @results = @boards = base_scope.in_category(@category).in_age_group(@age_group).page(params[:page])
    respond_to do |format|
      format.html {}
      format.pagination { render('shared/pagination', :formats => :html, :layout => false) }
    end
  end
    
  def set_filters
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
