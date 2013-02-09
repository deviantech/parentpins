module BookmarkletHelper
  
  def host
    port = ActionMailer::Base.default_url_options[:port]
    host = ActionMailer::Base.default_url_options[:host]
    port == 80 ? host : "#{host}:#{port}"
  end
  
end
