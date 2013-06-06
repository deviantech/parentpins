class ImportController < ApplicationController
  protect_from_forgery :except => [:step_1, :step_2] # Coming from JS, no way for bookmarklet to know proper CSRF token
  before_filter :authenticate_user!
  before_filter :parse_params
  layout 'import'


  # Given list of all pin data from external source, user will select which they want to import
  def step_1
    xBoard = Struct.new(:id, :name, :pins)
    @external_boards = []
    
    (@data[:import] ? @data[:import][:boards] : []).each do |board_id, board_info|
      board = xBoard.new(board_id, board_info[:name], board_info[:pins])
      pins = []
      board_info[:pins].each do |idx, pin_data|
        pins << Pin.from_pinterest(current_user, nil, pin_data)
      end
      board.pins = pins
      @external_boards << board
    end
    
    # TODO: figure out populating step1, using same formatted params as step2 (updated to parse both with same code). then move step1 to render from our site.
  end


  # Import step 2 - pull in data from external source for only those pins user wants to import (missing key components, so can't actually save pins yet). 
  # Also handle submitting the form to actually import some/all of them
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
    
    render 'imported' unless @imported.empty?
  end

  protected
  
  def parse_params
    # Bookmarklet sends initial data encoded in a single parameter, but for testing we may want to send parameters as normal
    @data = params[:data_string] ? Rack::Utils.parse_nested_query(params[:data_string]).with_indifferent_access : params.except("controller", "action")
    @data[:import] ||= {}
    @data[:import][:boards] ||= []
  end

end