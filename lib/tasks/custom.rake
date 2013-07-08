namespace :trends do  


  # Current logic - higher position == better. New pins get 0, so will show at very bottom until positions updated again
  desc "Update the trending calculations for pins and boards"
  task :update => :environment do
    puts "[#{Time.now}] Updating trends"
    batch_size = 1_000
    
    # Filter out boards with fewer than 5 pins
    Board.update_all ['trend_position=?', 0], ['pins_count < ?', 5]
    
    [Pin, Board].each do |klass|
      iterations = -1
      klass.update_all ['trend_position = ?', -1]
    
      loop do
        records = klass.unscoped.where(['trend_position = ?', -1]).order('rand()').limit(batch_size)
        break if records.empty?
        iterations += 1
        puts "\t- #{klass.name} iteration #{iterations + 1}"
        
        records.each_with_index do |record, idx|
          base_position = (batch_size * iterations) + idx
          modifier = if record.is_a?(Pin)
            record.likes_count + record.repins_count + trend_points_for_creation_date(record)
          else
            record.direct_followers_count + record.comments_count - (record.pins_count > 0 ? 0 : 200) # boards with pins first
          end
          
          position = base_position + (2 * modifier)  # Give slight preference to more popular items
          klass.update_all ['trend_position = ?', position], ['id = ?', record.id]             # Don't use AR here -- we're in an infinite loop, can't risk an invalid record preventing the save
        end
      end
    end
    puts "\t- Done updating trends."
  end
  
end

# Last week = 6 points, last month = 3 points, etc.
def trend_points_for_creation_date(obj)
  if    obj.created_at > 1.day.ago    then 20
  elsif obj.created_at > 1.week.ago   then 10
  elsif obj.created_at > 2.weeks.ago  then  5
  elsif obj.created_at > 3.weeks.ago  then  3
  else  0
  end
end

