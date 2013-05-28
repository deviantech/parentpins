class ImportController < ApplicationController
  protect_from_forgery :except => [:step_2] # Coming from JS, no way for bookmarklet to know proper CSRF token
  before_filter :authenticate_user!
  layout 'import'
  
  # Import step 2
  def step_2
    @pins_to_import = []
    @boards = []
    
    # TODO: remove this. in development, allow testing with 
    # http://localhost:3000/import/step_2?24%5B0%5D%5Bdescription%5D=Brandy+Melville+Tank+%2428&24%5B0%5D%5Bdomain%5D=saltandseaweed.com&24%5B0%5D%5Bprice%5D=%2428.00&24%5B0%5D%5BsmallImageURL%5D=http%3A%2F%2Fmedia-cache-ak1.pinimg.com%2F236x%2F06%2F49%2F09%2F06490959f16ea755c89e3b444a9e5686.jpg&24%5B0%5D%5BpinterestURL%5D=http%3A%2F%2Fpinterest.com%2Fpin%2F442126888388601214%2F&24%5B0%5D%5Bid%5D=511140869&24%5B0%5D%5Blink%5D=http%3A%2F%2Fwww.saltandseaweed.com%2Fcollections%2Fvendors%3Fq%3DBrandy%2BMelville&24%5B0%5D%5BimageURL%5D=http%3A%2F%2Fmedia-cache-ak1.pinimg.com%2F736x%2F06%2F49%2F09%2F06490959f16ea755c89e3b444a9e5686.jpg&24%5B1%5D%5Bdescription%5D=That's+How+a+Pro+Uses+a+Bunk+Bed&24%5B1%5D%5Bdomain%5D=memebase.cheezburger.com&24%5B1%5D%5Bprice%5D=&24%5B1%5D%5BsmallImageURL%5D=http%3A%2F%2Fmedia-cache-ak1.pinimg.com%2F236x%2F6e%2F06%2F34%2F6e063495136bfc91b8cfac6cd55e8557.jpg&24%5B1%5D%5BpinterestURL%5D=http%3A%2F%2Fpinterest.com%2Fpin%2F442126888388218505%2F&24%5B1%5D%5Bid%5D=1291275682&24%5B1%5D%5Blink%5D=http%3A%2F%2Fmemebase.cheezburger.com%2Fsenorgif&24%5B1%5D%5BimageURL%5D=http%3A%2F%2Fmedia-cache-ak1.pinimg.com%2F736x%2F6e%2F06%2F34%2F6e063495136bfc91b8cfac6cd55e8557.jpg&29%5B0%5D%5Bdescription%5D=Brandy+Melville+Tank+%2428&29%5B0%5D%5Bdomain%5D=saltandseaweed.com&29%5B0%5D%5Bprice%5D=%2428.00&29%5B0%5D%5BsmallImageURL%5D=http%3A%2F%2Fmedia-cache-ak1.pinimg.com%2F236x%2F06%2F49%2F09%2F06490959f16ea755c89e3b444a9e5686.jpg&29%5B0%5D%5BpinterestURL%5D=http%3A%2F%2Fpinterest.com%2Fpin%2F442126888388601214%2F&29%5B0%5D%5Bid%5D=511140869&29%5B0%5D%5Blink%5D=http%3A%2F%2Fwww.saltandseaweed.com%2Fcollections%2Fvendors%3Fq%3DBrandy%2BMelville&29%5B0%5D%5BimageURL%5D=http%3A%2F%2Fmedia-cache-ak1.pinimg.com%2F736x%2F06%2F49%2F09%2F06490959f16ea755c89e3b444a9e5686.jpg
   #  
    data = if params[:data_string] # Bookmarklet sends initial step_2 data encoded in a single parameter
      Rack::Utils.parse_nested_query(params[:data_string])
    else
      params.except("controller", "action")
    end
    
    data.each do |board_id, board_pins|
      board = current_user.boards.find(board_id)
      @boards << board
      board_pins.each do |idx, pin_data|
        pin = Pin.from_pinterest(current_user, board, pin_data)
        @pins_to_import << pin
      end
    end
  end
  
  # Not the prettiest nested params, but functional
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
