source 'http://rubygems.org'

# Note: under rails 4.0.1, Comment.new, User.new, etc. raises a "undefined method `[]' for nil:NilClass" error
gem 'rails', '4.0.0'

gem 'mysql2'
gem 'redis'
gem 'redis-namespace'
gem 'uuidtools'


gem 'sass-rails',   '~> 4.0.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'eco'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', :platforms => :ruby
gem 'uglifier', '>= 1.3.0'

# Handle non-digest asset requests - https://github.com/sikachu/sprockets-redirect.
# No rails 4 support merged in as of Oct 29, 2013
gem 'sprockets-redirect', :git => 'git@github.com:kjg/sprockets-redirect.git', :branch => :rails4

# For pinterest schema testing
gem 'capybara', :require => false
gem 'capybara-webkit', :require => false        # Note: requires qt to install. OSX: brew install qt. Ubuntu: sudo apt-get install libqt4-dev
gem 'capybara-user_agent', :require => false


# Avoid having to use strong params
gem 'protected_attributes'
gem 'dalli'

gem 'whenever', :require => false
gem 'unicorn', :require => false
gem 'subexec' # Used to manually run minimagick commands in store_average_color
gem 'rack-cors', :require => 'rack/cors'

gem 'dotenv-rails'

group :development do
  gem 'thin'
  gem 'ruby-debug', :platform => :ruby_18
  gem 'debugger',   :platform => :ruby_19
  gem 'pry-byebug', :platform => :ruby_20
  gem 'pry-rails'
  gem 'git'
  gem 'capistrano', '~> 2.15.5', :require => false
  gem 'capistrano-unicorn', :require => false
  gem 'capistrano-ext', :require => false
  gem 'capistrano_colors', :require => false
  gem 'capistrano-conditional', :git => 'git://github.com/deviantech/capistrano-conditional.git', :require => false
end

# TODO: when ALLOW_MAIL_PREVIEW is removed in favor of using in development only, put this in the development group
gem 'mail_view'

gem 'newrelic_rpm'
gem "bugsnag"


group :test do
  gem 'factory_girl_rails', :platform => [:ruby_19, :ruby_20]
  gem 'ffaker'
end

gem 'jquery-rails', '2.1.4' # 2.2.1 breaks pagination - maybe the jquery 1.9 part?
gem 'jquery-ui-rails'
gem 'will_paginate'
gem 'roadie'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

gem 'haml'
gem 'rails_autolink'

gem 'devise', '~> 3.1.1'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'

gem 'carrierwave'
gem 'carrierwave-meta'
gem 'carrierwave-mimetype-fu', '~> 0.0.2' #:path => "~/code/gems/carrierwave-mimetype-fu"
gem 'carrierwave_backgrounder', '~> 0.4.1'
gem 'sucker_punch', '~> 1.0'

gem 'mini_magick'
gem 'mime-types'
gem 'piet' # Requires "sudo apt-get install optipng jpegoptim" or "brew install optipng; brew install jpegoptim"
gem 'jcrop-rails-v2', "~> 0.9.12.2"

gem 'fog', "~> 1.18.0"
gem 'unf' # Optional dependency of fog, requiring gets rid of a warning in the logs

gem 'friendly_id', '~> 5.0.0'
gem 'aws-ses', '~> 0.5.0', :require => 'aws/ses'



# No longer needed on modern Ruby
gem 'system_timer', :platform => :ruby_18
gem 'aws-sdk', :require => false # Only used in rake tasks manually
