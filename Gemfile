source 'http://rubygems.org'

gem 'rails', '3.2.14'

gem 'mysql2'
gem 'redis'
gem 'redis-namespace'
gem 'uuidtools'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'turbo-sprockets-rails3'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'eco'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

# For pinterest schema testing
gem 'capybara', :require => false
gem 'capybara-webkit', :require => false        # Note: requires qt to install. OSX: brew install qt. Ubuntu: sudo apt-get install libqt4-dev
gem 'capybara-user_agent', :require => false


gem 'whenever', :require => false

group :development do
  gem 'awesome_print', :require => 'ap'
  gem 'thin'
  gem 'git'
  gem 'capistrano', :require => false
  gem 'rvm-capistrano', :require => false
  gem 'capistrano-ext', :require => false
  gem 'capistrano_colors', :require => false
  gem 'capistrano-conditional', :git => 'git://github.com/deviantech/capistrano-conditional.git', :require => false
end

# TODO: when ALLOW_MAIL_PREVIEW it removed in favor of development only, put this in the development group
gem 'mail_view'

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

gem 'capistrano'
gem 'ruby-debug', :platform => :ruby_18
gem 'debugger', :platform => [:ruby_19, :ruby_20]

gem 'haml'
gem 'rails_autolink'

gem 'devise', '~> 3.1.1'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'omniauth-twitter'

gem 'carrierwave'
gem 'mini_magick'
gem 'mime-types'
gem 'piet' # Requires "sudo apt-get install optipng jpegoptim" or "brew install optipng; brew install jpegoptim"
gem 'jcrop-rails-v2', "~> 0.9.12.2"




gem 'friendly_id'



# No longer needed on modern Ruby
gem 'system_timer', :platform => :ruby_18
