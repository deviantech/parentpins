# http://rubydoc.info/github/norman/friendly_id/master/file/Guide.rdoc
FriendlyId.defaults do |config|
  config.use :reserved
  
  config.reserved_words = %w(new edit update pin)
end
