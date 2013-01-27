class BoardsController < ApplicationController
  before_filter :authenticate_user!,  :except => [:index, :show]
  before_filter :find_my_board,       :only   => [:edit, :update, :destroy]
  before_filter :try_getting_user,    :only   => [:index, :show]
  before_filter :set_filters,         :only   => [:show, :index]
  layout :set_layout

  def index
    paginate_boards @profile ? @profile.boards : Board.trending    
  end

  def show
    @board = @profile.boards.find(params[:id])
    paginate_pins @board.pins
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

  def try_getting_user
    if @profile = User.find(params[:profile_id])
      get_profile_counters
    end
  rescue ActiveRecord::RecordNotFound => e
    true
  end

  def set_layout
    @profile ? 'profiles' : 'application'
  end

end