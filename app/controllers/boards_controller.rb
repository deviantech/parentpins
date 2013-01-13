class BoardsController < ApplicationController
  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :find_board, :only => [:edit, :update, :destroy]

  def index
    # TODO: implement some sort of trending logic
    @category = Category.find_by_id(params[:category]) unless params[:category].blank?
    @boards = Board.in_category(@category).limit(20)
  end

  def show
    @board = Board.find(params[:id])
    @pins = @board.pins.limit(20)
  end

  def new
    @board = current_user.boards.new(params[:board])
  end

  def create
    @board = current_user.boards.new(params[:board])
    if @board.save
      redirect_to board_profile_path(@board.user, @board), :notice => 'Created new board'
    else
      flash.now[:error] = "Unable to save board"
      render :action => 'new'
    end
  end

  def edit
    render :action => 'new'
  end

  def update
    if @board.update_attributes(params[:board])
      redirect_to @board, :notice => 'Saved changes to board'
    else
      flash.now[:error] = "Unable to save board"
      render :action => 'new'
    end
  end

  def destroy
    @board.destroy
    redirect_to boards_profile_path(current_user), :notice => 'Removed Board'
  end

  protected

  def find_board
    @board = current_user.boards.find(params[:id])
  end

end