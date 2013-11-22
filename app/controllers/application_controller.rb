class ApplicationController < ActionController::Base
  protect_from_forgery
  add_flash_types :error, :success
  before_filter :consider_ajax_layout
  helper_method :host, :bookmarklet_link_target_js
  before_filter :configure_permitted_parameters, if: :devise_controller?

  # TODO: remove this line once done testing media responsiveness
  before_filter :allow_external_iframing
  
  private
  
  def host
    port = ActionMailer::Base.default_url_options[:port]
    host = ActionMailer::Base.default_url_options[:host]
    port == 80 ? host : "#{host}:#{port}"
  end
    
  # Note: not using asset-path, because that uses a URL with a digest of the asset contents
  def bookmarklet_link_target_js
    %Q{javascript:void((function(b){var s=b.createElement('script');s.setAttribute('charset','UTF-8');s.setAttribute('type','text/javascript');s.setAttribute('src',"//#{host}/assets/bookmarklet.js?r="+Math.random()*999);b.body.appendChild(s);setTimeout(function(){if (!window.ppBookmarklet){alert("It seems we were unable to connect to the server. Please try again shortly.")}},4000);})(document))}
  end
  
  def get_profile_counters
    return true unless @profile 
    
    @profile_counters = {
      :pins         => @profile.pins.count,
      :boards       => @profile.boards.count,
      :likes        => @profile.likes_count,
      :followed_by  => @profile.followed_by_even_indirectly_count,
      :following    => @profile.following_even_indirectly_count
    }
  end

  def after_sign_in_path_for(user)
    if session[:user_return_to_from_pin].blank? && user.sign_in_count == 1
      activity_profile_path(user, :step_2 => true)
    else
      session[:user_return_to_from_pin] || stored_location_for(user) || activity_profile_path(user)
    end
  end

  def paginate_pins(base_scope)
    @results = @pins = base_scope.includes(:age_group).by_kind(@kind).in_category(@category).in_age_group(@age_group).page(params[:page]).per_page(10)
    support_ajax_pagination
  end

  # NOTE: similar to pins logic. Currently not used on general pages because we don't want to allow users to see how few boards we actually have.
  def paginate_boards(base_scope)
    @results = @boards = base_scope.includes(:category).in_category(@category).page(params[:page])
    support_ajax_pagination
  end

  def support_ajax_pagination(opts = {})
    # Note that if we render(@results) directly, the format gets confused and Rails won't find our templates
    layout_name = params[:controller] == 'import' ? 'import' : (@profile ? 'profile' : 'application')
    respond_to do |format|
      format.html { render(:layout => layout_name) }
      format.pagination { render('shared/pagination', :formats => :html, :layout => false) }
    end
  end
    
  def set_filters
    @kind = params[:kind] if Pin::VALID_TYPES.include?(params[:kind])
    
    cat_id = params[:category_id] || params[:category]
    @category = Category.where(:id => cat_id).first unless cat_id.blank?
    
    age_id = params[:age_group_id] || params[:age_group]
    @age_group = AgeGroup.where(:id => age_id).first unless age_id.blank?
    
    @filtered = @kind || @category || @age_group
  end
  
  def consider_ajax_layout
    # Returning false means no layout. Returning nil resets layout, and it will be set as usual by inheritance
    self.class.layout(params[:via] == 'ajax' ? false : nil)
  end

  # e.g. pin form has board fields, but even if they have values no new board should be created if user set the pin's board_id
  def conditionally_remove_nested_attributes(parent_model, nested_model)
    params[parent_model] ||= {}
    params[parent_model]["#{nested_model}_attributes"] ||= {} 

    # NOTE: if use for other associations, handle that they may not have user_id defined
    params[parent_model]["#{nested_model}_attributes"]['user_id'] = current_user.try(:id)
    return true if params[parent_model]["#{nested_model}_id"].blank?
    params[parent_model].delete("#{nested_model}_attributes")
  end

  def allow_external_iframing
    response.headers.except! 'X-Frame-Options'
  end
  
  # https://github.com/plataformatec/devise#strong-parameters
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :email
  end
end
