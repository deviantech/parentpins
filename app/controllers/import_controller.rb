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
    @context = :step_5
    @imported = []
    @pins_to_import = []
    
    @data[:pins].collect do |idx, attribs|
      pin = Pin.new(attribs, :without_protection => true) 
      if pin.save then @imported << pin
      else @pins_to_import << pin
      end
    end
    
    @boards = @pins_to_import.map(&:board).uniq
    if !@imported.empty? && @pins_to_import.empty?
      @body_class = 'import_completed'
      render 'imported'
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