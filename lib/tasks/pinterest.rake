require 'open-uri'

class PinterestChecker
  @@store_dir = Rails.root.join('db', 'pinterest-schema')
  
  def initialize
    @cookie = File.read( @@store_dir.join('cookies.txt') )
  end
  
  def get(url)
    open(url, 'Cookie' => @cookie).read
  end
  
  def set(url, label)
    File.open(@@store_dir.join("#{label}.html"), 'w') do |f|
      f << open(url, 'Cookie' => @cookie).read
    end
  end
  
  def changed?(url, label)
    File.read(@@store_dir.join("#{label}.html")) != get(url)
  end
end

namespace :pinterest do
  desc 'See if pinterest has made any changes to the pages we scrape'
  task :check_api_changes do
    # TODO: use cookie from db/pinterest-schema/cookies.txt to load the following URLs, then check against the stored contents (in same folder) and report if changes
    checker = PinterestChecker.new
    
    urls = {:single_board => "http://pinterest.com/dvntpins/default/", :multiple_boards => "http://pinterest.com/dvntpins/boards/", :single_pin => "http://pinterest.com/pin/442126888388183279/"}
    urls.each do |label, url|
      if checker.changed?(url, label)
        puts "[Pinterest Checker] #{label} has changed!"
      else
        puts "[Pinterest Checker] #{label} is OK"
      end
    end
  end
end

