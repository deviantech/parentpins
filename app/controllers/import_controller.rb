class ImportController < ApplicationController
  after_action :allow_external_iframing, :only => [:step_1]
  skip_before_filter :verify_authenticity_token, :only => [:step_1, :login_check] # Coming from JS, no way for bookmarklet to know proper CSRF token
  before_filter :authenticate_user!,  :except => [:login_check, :external_embedded]
  before_filter :parse_params,        :except => [:login_check, :external_embedded, :show]
  before_filter :get_profile_info,    :except => [:login_check, :external_embedded, :step_1]
  before_filter :set_filters,         :only =>   [:show]

  
  
  def external_embedded
    redirect_to '/', :error => "Unable to initiate ParentPin process -- it appears javascript wasn't enabled on the referring page."
  end
  
  # Note: using jsonp for this, which should make it work cross domain... but new browsers won't send cross domain ajax
  # as-is without CORS. CORS supports only newer browsers, so HOPEFULLY by using both side by side we can support old and new...
  # http://leopard.in.ua/2012/07/08/using-cors-with-rails/
  def login_check
    render :json => {:logged_in => current_user.try(:id)}, :callback => params[:callback]
  end

  # Assign pins to boards
  def step_1
    xBoard = Struct.new(:id, :name, :pins)
    @external_boards = []
    @data[:import][:boards].each do |board_id, board_info|
      board = xBoard.new(board_id, board_info[:name], board_info[:pins])
      board.pins = (board_info[:pins] || []).collect {|idx, p| Pin.from_pinterest(current_user, nil, p) }
      @external_boards << board
    end

    render :layout => 'external_import'
  end

  def step_2
    @context = :step_drag_to_assign
    craft_intermediate_pins
    session[:import_id] = current_user.imports.create(:source => params[:source] || 'pinterest', :attempted => @pins_to_import.length, :user_agent => request.user_agent).try(:id)
  end
  
  def step_3
    @context = :step_drag_to_assign
    craft_intermediate_pins
  end

  # Collect info & save new pins
  def step_4
    @context = :step_4
    craft_intermediate_pins
  end

  def step_5
    @imported = []
    @pins_to_import = []
    @import = session[:import_id] && current_user.imports.find(session[:import_id])
    
    (@data[:pins] || []).collect { |idx, attribs| Pin.new(attribs, :without_protection => true) }.each do |pin|
      pin.user = current_user
      pin.import = @import
      
      if pin.save then @imported << pin
      else @pins_to_import << pin
      end
    end
    @import && @import.increment(:completed, @imported.length)


    if @pins_to_import.empty? && @imported.empty?
      session.delete(:import_id)
      redirect_to profile_path(current_user), :error => "You successfully completed your import, but had no pins selected to save."
    elsif @pins_to_import.empty?
      session.delete(:import_id)
      redirect_to profile_import_path(current_user, @import, :just_completed => true), :success => "Congrats! You've just imported #{@imported.length} pin#{'s' unless @imported.length == 1}!"
    else
      if @imported.empty?
        flash.now[:error] = "Unable to save any pins -- please fill in the missing fields and try again"    
      else
        flash.now[:success] = "Imported #{@imported.length} pin#{'s' unless @imported.length == 1}! #{@pins_to_import.length} still need#{'s' if @pins_to_import.length == 1} tweaking, though."
      end
    
      @boards = @pins_to_import.map(&:board).uniq
      @context = :step_4
      render 'step_4'
    end
  end
  
  def show
    @context = :apply_normal_pin_styling
    if @import = current_user.imports.find(params[:id])
      paginate_pins @import.pins
    else
      redirect_to profile_path(current_user), :error => "Unable to locate specified import."
    end
  end

  protected
  
  def craft_intermediate_pins
    # Allow mass assignment, since we'll sanity check before saving the final version
    @pins_to_import = @data[:pins].collect { |idx, attribs| Pin.new(attribs, :without_protection => true) }
    @boards = @pins_to_import.map(&:board).uniq
  end
  
  def parse_params
    # Bookmarklet sends initial data encoded in a single parameter, but for testing we may want to send parameters as normal
    @data = params[:data_string] ? Rack::Utils.parse_nested_query(params.delete(:data_string)).with_indifferent_access : params.except("controller", "action")
    @data ||= {}
    @data[:import] ||= {}
    @data[:import][:boards] ||= []
  end

  def get_profile_info
    @profile = current_user
    get_profile_counters
  end

end