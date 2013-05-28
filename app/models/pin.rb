class Pin < ActiveRecord::Base  
  extend Searchable
  
  attr_accessor :cached_remote_image_url
  attr_accessible :kind, :description, :price, :url, :user_id, :board_id, :image, :image_cache, :remote_image_url, :via_url, :board_attributes, :age_group_id, :cached_remote_image_url

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
  
  belongs_to  :repinned_from,    :class_name => 'Pin',    :counter_cache => :repins_count
  has_many    :repins,           :class_name => 'Pin',    :foreign_key => 'repinned_from_id'
  
  has_many :comments, :dependent => :destroy, :as => :commentable

  accepts_nested_attributes_for :board
  
  before_validation :copy_board_settings,       :on => :create
  validates :user, :description, :board, :category, :age_group, :kind, :presence => true
  validates :kind,          :inclusion => {:in => VALID_TYPES, :message => "must be one of the supported types", :allow_blank => true}
  validates :description,   :length => {:maximum => 1024, :allow_blank => true}
  validate :validate_url_format, :not_previously_pinned, :on => :create
  
  before_save     :filter_url_before_save
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
  
  scope :with_image, where('image <> ""')
  
  scope :newest_first, order('id DESC')
  scope :not_ids, lambda {|ids| where(['id NOT IN (?)', Array(ids)]) }
  
  default_scope newest_first

  def repinned?
    !repinned_from_id.blank?
  end

  def self.trending
    # trend_position is not unique, but mysql will return in same order each time
    unscoped.order('trend_position DESC').group('url')
  end
  
  def self.from_pinterest(user, board, data)
    # Remove params used on the client side
    params = data.except('smallImageURL', 'pinterestURL', 'id', 'domain')
    params[:url] = params.delete('link')
    
    # TODO - set it in paraa as cached, but don't process until actually try to save the pin
    # params[:remote_image_url] = params.delete('imageURL')
    params[:cached_remote_image_url] = params.delete('imageURL')

    # TODO: add support for via_url, etc..
    
    pin = user.pins.new(params)
    pin.board_id = board.id
    return pin
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
    
    pin = Pin.new
    
    if source
      REPIN_ATTRIBUTES.each do |k|
        pin.send("#{k}=", source.send(k))
      end
      pin.attributes = other_params
      
      pin.original_poster = source.original_poster ? source.original_poster : source.user
      pin.original_poster = nil if pin.original_poster == user
      
      pin.repinned_from = source
      pin.via = source.user unless source.user == user
    else
      # user.pins.new(other_params) somehow doesn't allow creating new boards
      pin.attributes = other_params
    end

    pin.user = user
        
    if pin.board # If just created board from scratch
      pin.board.user_id ||= user.id
    else
      pin.board_id ||= user.last_board_pinned_to_id || user.boards.first.try(:id)
    end
    
    [source, pin]
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
  
  def likes_count
    Rails.redis.scard(redis_name__liked_by)
  end
  
  # ======================
  # = REDIS: queue names =
  # ======================    
  def redis_name__liked_by
    "p:#{self.id}:liked_by"
  end
  
  # Add our own affiliate tags wherever relevant
  def url
    return nil if self['url'].blank?
    
    appending = case self['url']
    when /amazon.com/i  then AFFILIATES[:amazon][:tag] ? "tag=#{AFFILIATES[:amazon][:tag]}" : nil
    else nil
    end
    
    [self['url'], appending].compact.join( self['url']['?'] ? '&' : '?' )
  end
  
  # Strip off just the filename component of the image, used to match previously imported pins
  def image_filename
    self['image']
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
  
  def validate_url_format
    raw = self['url'].to_s
    
    begin
      if raw.starts_with?(/https?/i)
        uri = URI.parse(raw)
      else
        uri = URI.join(self.via_url.to_s, raw)
        self.url = uri.to_s
      end
      
      self.domain = uri.host
    rescue
      errors.add(:url, "doesn't appear to be a valid link")
    end
  end
  
  # Before save, automatically edit URL to remove affiliate codes (we'll insert our own when displayed, rather than saving static codes in the DB).
  # Happens here because validation may change url, and not in url= because validation relies on other fields be set as well.
  def filter_url_before_save
    return true unless url_changed? && !self['url'].blank?
    raw = self['url'].to_s.strip
    raw = raw.sub(/tag=.+?(?:&|$)/, '') if raw =~ /amazon.com/i   # Remove amazon associate tag
    raw = raw.gsub(/&&+/, '&').sub(/[\?&]$/, '')                  # Trailing ? or &
    self.url = raw
  end
  
  
  def not_previously_pinned
    return true unless board
    return true if board.pins.where(:url => self.url).where(:image => image.filename).empty?
    errors.add :base, "You've already pinned that item on this particular board!"
  end

  def update_board_images_on_change
    return true unless board_id_changed?
    
    if old = Board.find_by_id(board_id_was)
      old.update_cover_before_pin_removed(self)
    end
    
    if future = Board.find_by_id(board_id)
      future.auto_set_cover_from_pin(self)
    end
  end

  def update_board_add_image
    board.try(:auto_set_cover_from_pin, self)
  end
  
  def update_board_remove_image
    board.try(:update_cover_before_pin_removed, self)
  end

  def track_board_last_pinned_to
    return true if cached_remote_image_url # Bulk importing, no need to track most recent board
    user.set_last_board_pinned_to_id(board_id)
  end
  
  def clean_redis
    # Clear self from other objects' redis entries
    liked_by.each {|u| u.unlike(self) }

    # Remove my redis objects
    Rails.redis.del(redis_name__liked_by)
  end

end
