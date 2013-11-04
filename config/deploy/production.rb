# Override deploy.rb defaults for the staging environment
set :deploy_to, "/var/www/#{application}/production"
set :rails_env, "production"

set :branch, fetch(:branch, "master")