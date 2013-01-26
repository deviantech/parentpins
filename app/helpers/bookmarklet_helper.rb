module BookmarkletHelper
  
  def host
    ActionMailer::Base.default_url_options[:host]
  end
  
end
