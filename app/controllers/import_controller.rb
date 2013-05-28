class ImportController < ApplicationController
  protect_from_forgery :except => [:step_2] # Coming from JS, no way for bookmarklet to know proper CSRF token
  before_filter :authenticate_user!
  layout 'import'

  # Import step 2 - pull in data passed from pinterest (missing key components, so can't actually save pins yet)
  def step_2
    @pins_to_import = []
    @boards = []

    # Bookmarklet sends initial step_2 data encoded in a single parameter, for testing we may want to send parameters as normal
    data = params[:data_string] ? Rack::Utils.parse_nested_query(params[:data_string]) : params.except("controller", "action")

    data.each do |board_id, board_pins|
      board = current_user.boards.find(board_id)
      @boards << board
      board_pins.each do |idx, pin_data|
        pin = Pin.from_pinterest(current_user, board, pin_data)
        @pins_to_import << pin
      end
    end
  end

  # End with same output as step_2, but from processing params from our own form (only display those that didn't save)
  def handle_step_2
    @pins_to_import = []
    @boards = []

    (params[:import] ? params[:import][:boards] : []).each do |board_id, pin_data_collection|
      next unless board = current_user.boards.find_by_id(board_id)

      pin_data_collection[:pins].each do |idx, data|
        pin = current_user.pins.new(data)
        pin.board = board

        unless pin.save
          @pins_to_import << pin
          @boards << board unless @boards.include?(board)
        end
      end
    end

    unless @pins_to_import.empty?
      render 'step_2'
    end
  end

end