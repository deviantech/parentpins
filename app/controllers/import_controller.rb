class ImportController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:step_1, :login_check] # Coming from JS, no way for bookmarklet to know proper CSRF token
  before_filter :authenticate_user!,  :except => [:login_check]
  before_filter :parse_params,        :except => [:login_check]
  before_filter :get_profile_info,    :except => [:login_check, :step_1]

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
    # Allow mass assignment, since we'll sanity check before saving the final version
    @pins_to_import = @data[:pins].collect { |idx, attribs| Pin.new(attribs, :without_protection => true) }
    @boards = @pins_to_import.map(&:board).uniq
    
    session[:import_id] = current_user.imports.create(:source => 'pinterest', :attempted => @pins_to_import.length, :user_agent => request.user_agent).try(:id)
  end
  
  def step_3
    @context = :step_drag_to_assign
    # Allow mass assignment, since we'll sanity check before saving the final version
    @pins_to_import = @data[:pins].collect { |idx, attribs| Pin.new(attribs, :without_protection => true) }
    @boards = @pins_to_import.map(&:board).uniq
  end

  # Collect info & save new pins
  def step_4
    @context = :step_4
    # Allow mass assignment, since we'll sanity check before saving the final version
    @pins_to_import = @data[:pins].collect { |idx, attribs| Pin.new(attribs, :without_protection => true) }
    @boards = @pins_to_import.map(&:board).uniq
  end

  def step_5
    @imported = []
    @pins_to_import = []
    @import = session[:import_id] && current_user.imports.find(session[:import_id])
          
    @data[:pins].collect { |idx, attribs| Pin.new(attribs, :without_protection => true) }.each do |pin|
      pin.user = current_user
      pin.import = @import
      
      if pin.save then @imported << pin
      else @pins_to_import << pin
      end
    end
    @import && @import.increment(:completed, @imported.length)

    if @pins_to_import.empty?
      flash.now[:success] = "Imported #{@imported.length} pin#{'s' unless @imported.length == 1}!"
      session.delete(:import_id)
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

  protected
  
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