class Pin < ActiveRecord::Base  
  extend Searchable
  attr_accessible :kind, :description, :price, :url, :user_id, :board_id, :image, :image_cache, :remote_image_url, :via_url, :board_attributes, :age_group_id

  VALID_TYPES = %w(idea product article)
  REPIN_ATTRIBUTES = %w(kind description price url age_group_id category_id image)

  mount_uploader :image, PinImageUploader

  extend FriendlyId
  friendly_id :uuid

  belongs_to :user
  belongs_to :via,              :class_name => 'User'
  belongs_to :original_poster,  :class_name => 'User'
  belongs_to :board,            :inverse_of => :pins,     :counter_cache => :pins_count
  belongs_to :category
  belongs_to :age_group
  
  belongs_to  :repinned_from,    :class_name => 'Pin',    :counter_cache => :repin_count
  has_many    :repins,           :class_name => 'Pin',    :foreign_key => 'repinned_from_id'
  
  has_many :comments, :dependent => :destroy, :as => :commentable

  accepts_nested_attributes_for :board
  
  before_validation :copy_board_settings,       :on => :create
  validates_presence_of :user, :description, :board, :category, :age_group
  validates_inclusion_of :kind, :in => VALID_TYPES
  validates_length_of :description, :maximum => 255, :allow_blank => true
  validate :url_format, :not_previously_pinned, :on => :create
  
  before_update   :update_board_images_on_change
  before_create   :set_uuid
  after_create    :update_board_add_image, :track_board_last_pinned_to
  before_destroy  :update_board_remove_image
  before_destroy  :clean_redis
  
  scope :by_kind, lambda {|kind|
    kind.blank? ? where('1=1') : where({:kind => kind})
  }
  scope :in_category, lambda {|cats|
    cats.blank? ? where('1=1') : where({:category_id => Array(cats).map(&:id)})
  }
  scope :in_age_group, lambda {|groups|
    groups.blank? ? where('1=1') : where({:age_group_id => Array(groups).map(&:id)})
  }
  scope :repinned, where('repinned_from_id IS NOT NULL')
  scope :not_repinned, where('repinned_from_id IS NULL')
  
  scope :with_image, where('image <> ""')
  
  scope :newest_first, order('id DESC')
  
  default_scope newest_first

  def self.trending
    # TODO: implement some sort of trending logic if kind/category aren't provided
    newest_first.not_repinned
  end
  
  def self.from_bookmarklet(user, params)
    # params[:url] is always the URL it was pinned from
    # params[:link], if present, means the image was linking to a new page. Show the new page instead (seems to be Pinterest's logic)
    pin = user.pins.new({
      :description => params[:description] || params[:title],
      :url => params[:link] ? params[:link] : params[:url],
      :via_url => params[:link] ? params[:url] : nil
    })
  end
  
  def user_id=(uid)
    super
    self.board_id ||= User.find(uid).last_board_pinned_to_id
  rescue ActiveRecord::RecordNotFound => e
    true
  end
  
  def remote_image_url=(str)
    apply_base64_image(str) || super
  end
  
  # If a source pin was passed in, copy relevant attributes (repin). Otherwise, generate a clean pin record.
  def self.craft_new_pin(user, source_id, other_params)
    source = begin
      !source_id.blank? && Pin.find(source_id)
    rescue ActiveRecord::RecordNotFound => e
      nil
    end
    
    the_pin = if source
      pin = Pin.new
      REPIN_ATTRIBUTES.each do |k|
        pin.send("#{k}=", source.send(k))
      end
      pin.attributes = other_params
      
      pin.original_poster = source.original_poster ? source.original_poster : source.user
      pin.original_poster = nil if pin.original_poster == user
      
      pin.repinned_from = source
      pin.via = source.user unless source.user == user
      pin.user = user
      pin.board_id ||= user.boards.first.try(:id)
      
      if pin.board # If just created board from scratch
        pin.board.user_id ||= user.id
      end
      
      pin
    else
      user.pins.new(other_params)
    end
    
    [source, the_pin]
  end
  
  # ===========================================================
  # = REDIS: Liked Pins (implementation partially in user.rb) =
  # ===========================================================

  def liked_by
    User.where(:id => liked_by_ids)
  end
  
  def liked_by_ids
    Rails.redis.smembers(redis_name__liked_by)
  end
  
  def liked_by_count
    Rails.redis.scard(redis_name__liked_by)
  end
  
  # ======================
  # = REDIS: queue names =
  # ======================    
  def redis_name__liked_by
    "p:#{self.id}:liked_by"
  end
    
  
  protected
  
  def set_uuid
    self.uuid ||= UUIDTools::UUID.timestamp_create().to_s
  end
  
  def apply_base64_image(string)
    return false unless string.match(/base64,?/)
    tempfile = Tempfile.new("base64file")
    tempfile.binmode
    tempfile.write( Base64.decode64( string.gsub(/.*base64,?/, '') ) )
    fname = SecureRandom.hex(16)
    self.image = ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :filename => fname, :original_filename => fname)
  end
  
  def copy_board_settings
    return true unless board
    self.category_id = board.category_id
  end
  
  def url_format
    begin
      if url.to_s.starts_with?(/https?/i)
        uri = URI.parse(url.to_s)
      else
        uri = URI.join(self.via_url.to_s, url.to_s)
        self.url = uri.to_s
      end
      
      self.domain = uri.host
    rescue
      errors.add(:url, "doesn't appear to be a valid link")
    end
  end
  
  def not_previously_pinned
    return true unless board
    return true if board.pins.where(:url => self.url).where(:image => image.filename).empty?
    errors.add :base, "You've already pinned this on this board!"
  end

  def update_board_images_on_change
    return true unless board_id_changed?
    
    if old = Board.find_by_id(board_id_was)
      old.update_cover_before_pin_removed(self)
    end
    
    if future = Board.find_by_id(board_id)
      future.set_cover_from_pin(self)
    end
  end

  def update_board_add_image
    board.try(:set_cover_from_pin, self)
  end
  
  def update_board_remove_image
    board.try(:update_cover_before_pin_removed, self)
  end

  def track_board_last_pinned_to
    user.set_last_board_pinned_to_id(board_id)
  end
  
  def clean_redis
    # Clear self from other objects' redis entries
    liked_by.each {|u| u.unlike(self) }

    # Remove my redis objects
    Rails.redis.del(redis_name__liked_by)
  end

end
