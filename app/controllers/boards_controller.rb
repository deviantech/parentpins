class BoardsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]

  def index
    # TODO: implement some sort of trending logic
    @category = Category.find_by_id(params[:category]) unless params[:category].blank?
    @boards = Board.in_category(@category).limit(20)
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
    render :action => 'new'
  end
  
  def update
    @board = current_user.boards.find(params[:id])
    if @board.update_attributes(params[:board])
      redirect_to @board, :notice => 'Saved changes to board'
    else
      flash.now[:error] = "Unable to save board"
      render :action => 'new'
    end
  end
  
  def destroy
    # TODO - implement me
  end
  
end