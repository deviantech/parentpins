class ImportController < ApplicationController
  skip_before_filter :verify_authenticity_token, :except => [:step_3] # Coming from JS, no way for bookmarklet to know proper CSRF token
  before_filter :authenticate_user!,  :except => [:login_check]
  before_filter :parse_params,        :except => [:login_check]
  layout 'import'

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
  end


  def step_2_new
    @pins_to_import = []
    @boards = []

    @data[:import][:boards].each do |board_id, board_info|
      next unless board = current_user.boards.find_by_id(board_id)

      board_info[:pins].each do |idx, data|
        pin = Pin.from_pinterest(current_user, board, data)
        @pins_to_import << pin
        @boards << board unless @boards.include?(board)
      end
    end
  end
  
  def step_3
    # Allow mass assignment, since we'll sanity check before saving the final version
    @pins_to_import = @data[:pins].collect { |idx, attribs| Pin.new(attribs, :without_protection => true) }
    @boards = @pins_to_import.map(&:board).uniq
  end

  # Collect info & save new pins
  def step_2
    @pins_to_import = []
    @boards = []
    @imported = []

    @data[:import][:boards].each do |board_id, board_info|
      next unless board = current_user.boards.find_by_id(board_id)

      board_info[:pins].each do |idx, data|
        pin = Pin.from_pinterest(current_user, board, data)

        if @data[:from] == 'importer' || !pin.save
          @pins_to_import << pin
          @boards << board unless @boards.include?(board)
        else
          @imported << pin
        end
      end
    end
    
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

end