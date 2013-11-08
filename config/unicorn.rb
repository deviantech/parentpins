# unicorn_rails -c /data/github/current/config/unicorn.rb -E production -D
# TODO: restyle from http://crosbymichael.com/setup-ruby-on-rails-with-nginx-and-unicorn.html
# TODO: http://ariejan.net/2011/09/14/lighting-fast-zero-downtime-deployments-with-git-capistrano-nginx-and-unicorn/
# TODO: consider puma - http://blog.wiemann.name/rails-server

# Set your full path to application.
rails_env = ENV['RAILS_ENV'] || 'production'

app_path = "/var/www/pins/#{rails_env}/current"
shared_path = "/var/www/pins/#{rails_env}/shared"
 
worker_processes (rails_env == 'production' ? 2 : 1)
preload_app true
timeout 60
 
# Listen on a Unix data socket
listen "#{shared_path}/sockets/unicorn.sock", :backlog => 2048
pid "#{shared_path}/pids/unicorn.pid"

# Log everything to one file
stderr_path "log/unicorn.log"
stdout_path "log/unicorn.log"




working_directory app_path

 
 
GC.copy_on_write_friendly = true if GC.respond_to?(:copy_on_write_friendly=)

# http://kavassalis.com/2013/04/unicorn-hot-restarts-my-definitive-guide/ 
before_exec do |server|
   ENV['BUNDLE_GEMFILE'] = "#{app_path}/Gemfile"
end

before_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
  
  
  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.
 
  old_pid = RAILS_ROOT + '/tmp/pids/unicorn.pid.oldbin'
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end
 
 
after_fork do |server, worker|
  
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection 
 
  ##
  # Unicorn master is started as root, which is fine, but let's
  # drop the workers to ubuntu:ubuntu
 
  begin
    uid, gid = Process.euid, Process.egid
    user, group = 'ubuntu', 'ubuntu'
    target_uid = Etc.getpwnam(user).uid
    target_gid = Etc.getgrnam(group).gid
    worker.tmp.chown(target_uid, target_gid)
    if uid != target_uid || gid != target_gid
      Process.initgroups(user, target_gid)
      Process::GID.change_privilege(target_gid)
      Process::UID.change_privilege(target_uid)
    end
  rescue => e
    if RAILS_ENV == 'development'
      STDERR.puts "couldn't change user, oh well"
    else
      raise e
    end
  end
end
