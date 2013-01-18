class BoardsController < ApplicationController
  before_filter :authenticate_user!,  :except => [:index, :show]
  before_filter :find_board,          :only   => [:edit, :update, :destroy]
  before_filter :set_filters,         :only   => [:show, :index]

  def index
    # TODO: implement some sort of trending logic
    @category = Category.find_by_id(params[:category]) unless params[:category].blank?
    @boards = Board.in_category(@category).in_age_group(@age_group).limit(20)
  end

  def show
    @board = Board.find(params[:id])
    paginate_pins @board.pins
  end

  def new
    @board = current_user.boards.new(params[:board])
  end

  def create
    @board = current_user.boards.new(params[:board])
    if @board.save
      # Allow returning back to pin if opened because trying to create pin with no return yet
      url = session.delete(:post_board_url)
      url ||= board_profile_path(@board.user, @board)
      redirect_to url, :notice => 'Created new board'
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