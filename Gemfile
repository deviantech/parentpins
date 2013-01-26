source 'https://rubygems.org'

gem 'rails', '3.2.11'

gem 'mysql2'
gem 'redis'
gem 'redis-namespace'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sprockets-commonjs'
  gem 'turbo-sprockets-rails3'
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'eco'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development do
  gem 'thin'
  gem 'mini_magick'  
  gem 'git'
  gem 'capistrano', :require => false
  gem 'rvm-capistrano', :require => false
  gem 'capistrano-ext', :require => false
  gem 'capistrano_colors', :require => false
  gem 'capistrano-conditional', :git => 'git://github.com/deviantech/capistrano-conditional.git', :require => false  
end

gem 'jquery-rails'
gem 'will_paginate'
gem 'roadie'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

gem 'capistrano'
gem 'ruby-debug', :platform => :ruby_18
gem 'debugger', :platform => :ruby_19

gem 'haml'

gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'

# Used for carrerwave uploads. NOTE that this requires libvips, with either of:
#   apt-get install libvips-dev
#   brew install --use-llvm vips
# And add to zsh profile:
# =>  export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/usr/X11/lib/pkgconfig
gem 'carrierwave'
gem 'mime-types'

group :production do
  gem 'ruby-vips'
  gem 'carrierwave-vips'
end



gem 'friendly_id'

gem 'system_timer', :platform => :ruby_18