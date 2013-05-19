class ImportController < ApplicationController
  protect_from_forgery :except => [:step_2] # Coming from JS, no way for bookmarklet to know proper CSRF token
  before_filter :authenticate_user!
  layout 'import'
  
  # Import step 2
  def step_2
    @boards = []
    @importing = {}
    if params[:data_string] # Bookmarklet sends initial step_2 data encoded in a single parameter
      data = Rack::Utils.parse_nested_query(params[:data_string])

      data.each do |board_id, board_pins|
        @boards << current_user.boards.find(board_id)
        @importing[board_id.to_i] = []
        board_pins.each do |idx, pin_data|
          @importing[board_id.to_i] << Pin.from_pinterest(current_user, pin_data)
        end
      end
    end
  end

end
