class AjaxController < ApplicationController
  
  def board
    @board = Board.find(params[:id])
    render :partial => 'board/board', :object => @board, :layout => false
  end
  
end
