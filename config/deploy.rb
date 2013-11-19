# TODO: http://www.capistranorb.com/documentation/upgrading/

require "capistrano-conditional"
require 'capistrano/ext/multistage'
require "bundler/capistrano"
# require 'thinking_sphinx/deploy/capistrano'


IN_VAGRANT = ENV['VAGRANT']

if IN_VAGRANT
  require 'capistrano-unicorn'
  set :application, "pins"
  set :site_ip, '33.33.33.10'
  set :default_environment, {
    'PATH' => "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH"
  }
else
  require "rvm/capistrano"
  set :application, "parentpins"
  set :rvm_type, :system
  set :site_ip, '54.204.12.77'
end

set :whenever_command,     "bundle exec whenever"
set :whenever_environment, defer { stage }
set :whenever_identifier,  defer { "#{application}_#{stage}" }
require "whenever/capistrano"

# Stages
set :stages, %w(staging production)
set :default_stage, "production"

# SCM info
set :scm, :git
set :repository, "git@github.com:deviantech/parentpins.git"
set :deploy_via, :remote_cache
set :scm_verbose, true
set :git_enable_submodules, 1


# SSH info
set :user, 'ubuntu'
default_run_options[:pty] = true
set :ssh_options, { :forward_agent => true, :compression => "none" }

# Configure roles
role :app, site_ip
role :web, site_ip
role :db,  site_ip, :primary => true

# Clean up deploys automatically
set :keep_releases, 3
after "deploy", "deploy:cleanup"


# =========
# = Tasks =
# =========


ConditionalDeploy.monitor_migrations(self)

ConditionalDeploy.register :whenever, :watchlist => 'config/schedule.rb' do
  after "deploy:create_symlink", "deploy:update_crontab"
end

# ConditionalDeploy.register :sphinx, :watchlist => ['db/schema.rb', 'db/migrate', 'sphinx.yml'] do
#   # Both automatically run configure
#   before "deploy:update_code", "thinking_sphinx:stop"
#   before "deploy:start", "thinking_sphinx:start"
#   before "deploy:restart", "thinking_sphinx:start"
# end
# ConditionalDeploy.register :no_sphinx, :none_match => ['db/schema.rb', 'db/migrate'] do
#   after "deploy:update_code", "sphinx:copy_config"
# end

# ===================================
# = Currently deployed on passenger =
# ===================================
if IN_VAGRANT
  # after 'deploy:restart', 'unicorn:reload'    # app IS NOT preloaded
  # after 'deploy:restart', 'unicorn:restart'   # app preloaded
  after 'deploy:restart', 'unicorn:duplicate' # before_fork hook implemented (zero downtime deployments)
else
  namespace :deploy do
    desc "Restarting passenger with restart.txt"
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "touch #{current_path}/tmp/restart.txt"
    end

    [:start, :stop].each do |t|
      desc "#{t} task is a no-op with mod_rails"
      task t, :roles => :app do ; end
    end
  end
end


namespace :deploy do
  namespace :assets do

    def not_first_deploy?
      'true' ==  capture("if [ -e #{current_path}/REVISION ]; then echo 'true'; fi").strip
    end

    desc "Run the asset precompilation rake task only if there are changes."
    task :precompile, :roles => :web, :except => { :no_release => true } do
      if not_first_deploy?
        from = source.next_revision(current_revision)
        if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ Gemfile.lock | wc -l").to_i > 0
          run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
        else
          logger.info "Skipping asset pre-compilation because there were no asset changes"
        end
      end
    end
    
  end
end


# =====================================
# = Updating crontab for whenever gem =
# =====================================
namespace :deploy do
  desc "Update the crontab file"
  task :update_crontab, :roles => :db do
    run ". /etc/profile.d/rvm.sh && cd #{current_path} && whenever --update-crontab #{application}_#{stage} --set environment=#{rails_env}"
  end
end

# ===========================
# = Custom disabled message =
# ===========================
namespace :deploy do
  namespace :web do
    task :disable, :roles => :web do
      # invoke with
      # UNTIL="16:00 MST" REASON="a database upgrade" cap deploy:web:disable

      on_rollback { rm "#{shared_path}/system/maintenance.html" }

      require 'erb'
      deadline, reason, explanation = ENV['UNTIL'], ENV['REASON'], ENV['EXPLANATION']
      maintenance = ERB.new(File.read("./app/views/layouts/maintenance.html.erb")).result(binding)

      put maintenance, "#{shared_path}/system/maintenance.html", :mode => 0644
    end
  end
end



# =====================
# = Development tasks =
# =====================
namespace :dev do
  desc 'Overwrite development database with remote data'
  task :db_dup do
    puts "This will overwrite ALL DEVELOPMENT DATA and replace it with a copy of the #{stage.to_s.upcase} database. OK? (y/N): "
    if !STDIN.gets.match(/y/i)
      puts "Quitting without doing anything"
    else
      dbname = stage == :production ? application : "#{application}_#{stage}"
      unless ENV['SKIP_DUMP']
        puts "Dumping #{stage} DB on server"
        run "mysqldump -u root #{dbname} > #{dbname}.sql"
        puts "Dumped #{stage} DB to file #{dbname}.sql"
      end
      
      download "#{dbname}.sql", "tmp/#{dbname}.sql"
      puts "Downloaded to local computer"
      
      dbconf = YAML.load_file( File.expand_path('./config/database.yml') )
      devdb = dbconf['development']['database']
      puts "Importing into local development DB #{devdb}"
      
      run_locally("mysql -u root #{devdb} < tmp/#{dbname}.sql")
      run_locally("rm tmp/#{dbname}.sql")
      puts "Done!"
    end
  end
end


# ===========
# = Symlink =
# ===========
after 'deploy:create_symlink', 'create_app_symlinks'

task :create_app_symlinks do
  # Sphinx configs here?
  
end