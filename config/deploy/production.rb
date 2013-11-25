# Override deploy.rb defaults for the staging environment
set :deploy_to, "/var/www/#{application}/production"
set :rails_env, "production"
ENV['RAILS_ENV'] = 'production' # Needed for unicorn:stop

set :branch, fetch(:branch, "master")