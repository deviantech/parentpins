class BoardsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  def index
    @boards
  end
  
  def show
    @board = Board.find(params[:id])
  end
  
  def new
    @board = current_user.boards.new(params[:board])
  end
  
  def create
    @board = current_user.boards.new(params[:board])
    if @board.save
      redirect_to @board, :notice => 'Created new board'
    else
      flash.now[:error] = "Unable to save board"
      render :action => 'new'
    end
  end
  
  def edit
    @board = current_user.boards.find(params[:id])
  end
  
  def update
    @board = current_user.boards.find(params[:id])
  end
  
end