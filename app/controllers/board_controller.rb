class BoardController < ApplicationController
  before_filter :authenticate_user!,  :except => [:index, :show, :comments]
  before_filter :try_getting_user,    :only   => [:index, :show, :comments, :follow, :unfollow]
  before_filter :find_my_board,       :only   => [:edit, :update, :edit_cover, :update_cover, :destroy]
  before_filter :find_profile_board,  :only   => [:show, :comments, :follow, :unfollow]
  before_filter :set_filters,         :only   => [:show, :index]
  layout :set_layout

  def index
    if @profile
      paginate_boards @profile.boards
    else
      # Not paginating in any general contexts to avoid showing users exactly how few boards we have
      @results = @boards = Board.includes([:user, :category]).in_category(@category).trending.where('pins_count > ?', 5).limit(75)
    end
  end

  def show
    paginate_pins @board.pins
  end

  def sort
    # Might get odd results if not all boards are passed (e.g. duplicate positions), but it's nothing mission critical
    current_user.boards.each do |b|
      b.update_attribute :position, params[:boards].index(b.id.to_s).to_i + 1
    end
    render :nothing => true
  end

  def new
    @remotely = request.referer.to_s =~ /import\/step_1/ # If from import controller, save form via ajax
    @board = current_user.boards.new(params[:board])
  end

  def create
    @board = current_user.boards.create(params[:board])
    
    respond_to do |format|
      format.js {}
      format.html {
        if @board.new_record?
          flash.now[:error] = "Unable to save board"
          render :action => 'new'
        else
          redirect_to profile_board_path(@board.user, @board)
        end
      }
    end
  end

  def edit
    render :action => 'new'
  end

  def edit_cover
  end
  
  def update_cover
    params[:board] ||= {}
    @board.set_cover_source(params[:board][:cover_source_id])
  end

  def update
    if @board.update_attributes(params[:board])
      redirect_to profile_board_path(@board.user, @board), :notice => 'Saved changes to board.'
    else
      flash.now[:error] = "Unable to save board"
      render :action => 'new'
    end
  end

  def destroy
    @board.destroy
    redirect_to profile_boards_path(current_user), :notice => %Q{Removed Board: "#{@board.name}".}
  end
  
  def comments
    params[:page] ||= 1
    @comments = @board.comments.page(params[:page])
  end
  
  def follow
    current_user.follow(@board) if user_signed_in?
    render :nothing => true
  end
  
  def unfollow
    current_user.unfollow(@board) if user_signed_in?
    render :nothing => true
  end

  protected

  def find_my_board
    @board = current_user.boards.find(params[:id])
  end
  
  def find_profile_board
    @board = @profile.boards.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    redirect_to profile_path(@profile)
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