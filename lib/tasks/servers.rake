namespace :servers do
  
  # 0. bring up new server with no data
  # 1. run cap deploy:web:disable on the old server (to prevent changes to DB while migrating)
  # RUN THIS SCRIPT TO SET UP NEW SERVER: 
  #     To test:  bx rake servers:move_data OLD=parentpins.com NEW=staging.parentpins.com DB_OLD=pins DB_NEW=pins_staging
  #     For prod: bx rake servers:move_data OLD=parentpins.com NEW=staging.parentpins.com DB_OLD=pins
  # 2. change DNS to point to new server (leave old in migration mode to prevent serving from old accidentally, or set ip redirect)
  # 3. profit
  
  desc 'Move data to new server'
  task :move_data do

    s_old = ENV['OLD']
    s_new = ENV['NEW']
    db_old = ENV['DB_OLD']
    db_new = ENV['DB_NEW'] || db_old
    
    raise "Missing required variables" unless s_old && s_new && db_old && db_new
    
    # MySQL
    puts "* Migrating MYSQL data from #{s_old} (#{db_old}) to #{s_new} (#{db_new})"
    run %Q{ssh #{s_old} "mysqldump -u root #{db_old} > #{db_old}.sql"}
    run %Q{scp #{s_old}:#{db_old}.sql tmp/#{db_old}.sql}
    run %Q{scp tmp/#{db_old}.sql #{s_new}:#{db_new}.sql}
    run %Q{ssh #{s_new} "mysql -u root #{db_new} < #{db_new}.sql"}
    
    # # Redis
    puts "\n\n* Migrating REDIS data from #{s_old} to #{s_new}"
    run %Q{ssh #{s_old} "redis-cli SAVE && sudo chmod 777 /var/lib/redis/dum*.rdb && cp /var/lib/redis/dum*.rdb ~/redis.rdb"}
    run %Q{scp #{s_old}:redis.rdb tmp/redis.rdb}
    run %Q{scp tmp/redis.rdb #{s_new}:redis.rdb}
    run %Q{ssh #{s_new} "sudo chown redis:redis redis.rdb"}
    run %Q{ssh #{s_new} "sudo stop redispins"}
    run %Q{ssh #{s_new} "sudo rm -f /var/lib/redis/dump-pins.rdb && sudo mv redis.rdb /var/lib/redis/dump-pins.rdb"}
    run %Q{ssh #{s_new} "sudo start redispins"}
  end
  
  def run(cmd)
    puts "\t Running: #{cmd}"
    `#{cmd}`
  end
end
