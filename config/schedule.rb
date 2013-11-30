# Use this file to easily define all of your cron jobs.


# Runs like normal, but uses the current symlink so we don't have to update whenever on every deploy
def current(cmd_type, cmd_str)
  @full_path ||= File.expand_path( File.dirname(__FILE__) ).gsub(/\/config/, '')
  @curr_path ||= @full_path['/releases/'] ? @full_path.gsub(/releases\/\d+/, 'current') : @full_path  
  
  send(cmd_type, cmd_str, :path => @curr_path)
end

# Bundle exec rake TASK 
job_type :current_command, "cd :path && :task :output"
job_type :bx_rake, "cd :path && bundle exec rake :task --silent :output RAILS_ENV=:environment"


set :output, File.join(File.expand_path( File.dirname(__FILE__) ).gsub(/releases\/\d+/, 'current'), '..', 'log', 'cron_log.log')



every 1.day do
  current :bx_rake, "trends:update"
end

every :day do
  current :current_command, "test/external/pinterest.rb"
end

