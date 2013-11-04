namespace :trends do  


  # Current logic - higher position == better. New pins get 0, so will show at very bottom until positions updated again
  desc "Update the trending calculations for pins and boards"
  task :update => :environment do
    puts "[#{Time.now}] Updating trends"
    batch_size = 1_000
    
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


namespace :admin do
  desc "Send an admin alert email"
  task :alert, [:message] => :environment do |t, args|
    msg = AdminMailer.alert_to_admin( args[:message] )
    puts msg.body
    msg.deliver
  end
end


namespace :pins do
  desc "Update missing image height for existing pins"
  task :update_heights => :environment do

    Pin.send(:define_method, :hackish_height) do
      @height = 0
      self.image.v222.manipulate! do |img|
        @height = img[:height]
        img
      end
      @height
    end

    total = Pin.where('image_v222_height IS NULL').where.not('image IS NULL').count
    current = 0
    puts "Found #{total} pins to update"
    Pin.where('image_v222_height IS NULL').where.not('image IS NULL').find_each(:batch_size => 100) do |pin|
      current += 1
      puts "#{current} of #{total}" if current % 10 == 0
      pin.update_attribute :image_v222_height, pin.hackish_height
    end
    
  end
end