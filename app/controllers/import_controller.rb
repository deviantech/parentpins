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


  # Import step 2 - pull in data from external source for only those pins user wants to import (missing key components, so can't actually save pins yet)
  def step_2
    @pins_to_import = []
    @boards = []

    @data.each do |board_id, board_pins|
      board = current_user.boards.find(board_id)
      @boards << board
      board_pins.each do |idx, pin_data|
        pin = Pin.from_pinterest(current_user, board, pin_data)
        @pins_to_import << pin
      end
    end
    
    # TODO: rewrite to avoid needing handle_step_2. if fail, extend import.js.coffee to run step_2 code on handle_step_2 action name as well.
  end

  # End with same output as step_2, but from processing params from our own form (only display those that didn't save)
  def handle_step_2
    @pins_to_import = []
    @boards = []
    @imported = []

    (@data[:import] ? @data[:import][:boards] : []).each do |board_id, board_info|
      next unless board = current_user.boards.find_by_id(board_id)

      board_info[:pins].each do |idx, data|
        pin = current_user.pins.new(data)
        pin.board = board

        if pin.save
          @imported << pin
        else
          @pins_to_import << pin
          @boards << board unless @boards.include?(board)
        end
      end
    end

    unless @pins_to_import.empty?
      render 'step_2'
    end
  end

  protected
  
  def parse_params
    # Bookmarklet sends initial data encoded in a single parameter, but for testing we may want to send parameters as normal
    @data = params[:data_string] ? Rack::Utils.parse_nested_query(params[:data_string]).with_indifferent_access : params.except("controller", "action")
  end

end