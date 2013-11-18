# Override deploy.rb defaults for the staging environment
set :deploy_to, "/var/www/#{application}/staging"
set :rails_env, "staging"

set :branch, fetch(:branch, "master")