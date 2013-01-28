class BoardController < ApplicationController
  before_filter :authenticate_user!,  :except => [:index, :show, :comments]
  before_filter :try_getting_user,    :only   => [:index, :show, :comments]
  before_filter :find_my_board,       :only   => [:edit, :update, :destroy]
  before_filter :find_profile_board,  :only   => [:show, :comments]
  before_filter :set_filters,         :only   => [:show, :index]
  layout :set_layout

  def index
    paginate_boards @profile ? @profile.boards : Board.includes([:user]).trending    
  end

  def show
    paginate_pins @board.pins
  end

  def new
    @board = current_user.boards.new(params[:board])
  end

  def create
    @board = current_user.boards.new(params[:board])
    if @board.save
      redirect_to profile_board_path(@board.user, @board), :notice => 'Created new board'
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
      redirect_to profile_board_path(@board.user, @board), :notice => 'Saved changes to board'
    else
      flash.now[:error] = "Unable to save board"
      render :action => 'new'
    end
  end

  def destroy
    @board.destroy
    redirect_to profile_boards_path(current_user), :notice => 'Removed Board'
  end
  
  def comments
    params[:page] ||= 1
    @comments = @board.comments.page(params[:page])
  end

  protected

  def find_my_board
    @board = current_user.boards.find(params[:id])
  end
  
  def find_profile_board
    @board = @profile.boards.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    redirect_to profile_path(@profile), :notice => 'Unable to find board'
  end

  def try_getting_user
    if @profile = User.find(params[:profile_id])
      get_profile_counters
    end
  rescue ActiveRecord::RecordNotFound => e
    true
  end

  def set_layout
    @profile ? 'profile' : 'application'
  end

end