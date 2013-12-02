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
  
  # Used once to store height for already-uploaded pins when we started tracking that information
  # Run as 'nohup bundle exec rake pins:update_meta RAILS_ENV=production &' && 'disown %1' && 'sudo renice -10 PID'
  desc "Update missing image height for existing pins"
  task :update_meta => :environment do
    total = Pin.where('image_average_color IS NULL').where.not('image IS NULL').count
    current = 0
    puts "Found #{total} pins to update"
    
    Pin.where('image_average_color IS NULL').where.not('image IS NULL').find_each(:batch_size => 100) do |pin|
      current += 1
      puts "#{current} of #{total}" if current % 10 == 0
      begin
        pin.image.v222.send(:get_dimensions) # Automatically sets height, width, and image_average_color
        pin.save
      rescue StandardError => e
        msg = "[#{pin.id}] (#{pin.image.v222.url}) failed to detect dimensions (valid image?)"
        puts msg
        File.open('log/pinerrors.log', 'a') {|f| f.puts msg}
      end
    end
  end
  
  # Pre-launch only. Update timestamps on every pin to be randomly between board creation and now. Bias toward more recently.
  desc 'Randomize creation dates for pins to be more recent'
  task :update_creation_dates => :environment do
    def rand_in_range(from, to)
      rand * (to - from) + from
    end

    User.test_users.includes(:boards).each do |user|
      user.boards.includes(:pins).find_each do |b|
        puts "Updating #{user.name}'s board #{b.id} (#{b.pins.count} pins)"
        if b.created_at < 6.months.ago
          b.created_at = b.updated_at = b.created_at + (((Time.now - b.created_at) / 3600 / 24 / 30) - 1).to_i.months
        end
        
        oldest = Time.now - b.created_at
        b.pins.to_a.shuffle.each_with_index do |p, i|
          offset = rand_in_range(0, oldest / (i+1))
          date = Time.now - offset
          # Not mass-assigning
          p.created_at = date
          p.updated_at = date
          p.save!
          puts "\tPin #{p.id} has #{p.comments.where('created_at < ?', date).count} comments which are older than the new minimum date. Fixing." if p.comments.where('created_at < ?', date).count > 0
          p.comments.where('created_at < ?', date).each_with_index do |c, i|
            newdate = date + (i * 10).minutes
            c.created_at = newdate
            c.updated_at = newdate
            c.save!
          end
        end
        
        earliest_comment_date = (b.pins.sort_by(&:created_at).first || b).created_at
        b.comments.each do |c|
          next unless c.created_at < earliest_comment_date
          puts "\tFixing an old board comment for #{b.id}"
          date = earliest_comment_date + ((Time.now - earliest_comment_date) / 3600 / 24).to_i.days
          c.updated_at = date
          c.created_at = date
          c.save!
        end
        
      end
    end
  end
end

namespace :uploads do
  desc 'Run ONCE after moving to [uploader]_token naming system'
  task :update_names => :environment do
    require 'aws-sdk'
    s3 = AWS.s3
    bucket = s3.buckets[CARRIERWAVE[:bucket]]
    
    puts "Updating avatars"
    User.where.not(:avatar => nil).find_each do |model|
      old_base = Digest::MD5.hexdigest("#{model.class.name}.#{model.id}")
      bucket.objects.with_prefix("uploads/user/avatar/#{model.id}/").each do |obj|
        new_name = obj.key.sub(/[\da-zA-Z]{16}/, model.avatar_token)
        # if obj.key =~ /#{old_base}/
        #   new_name = obj.key.gsub(/#{old_base}/, model.avatar_token)
        #   if new_name =~ /main_/
        #     new_name = new_name.sub(/main_/, '').sub(/#{model.avatar_token}/, "#{model.avatar_token}_cropped_#{model.avatar.send(:crop_args).join('_')}")
        #   end
          puts "\t[#{model.id}] Moving #{obj.key} to #{new_name}"
          obj.move_to new_name, :acl => :public_read, :cache_control => 'public, max-age=315576000', :content_type => obj.content_type
        # else
        #   puts "[#{model.id}] Deleting #{obj.key} (doesn't match #{old_base})"
        #   obj.delete
        # end
        model.save
      end
    end
    
    puts "\n\nUpdating cover images"
    User.where.not(:cover_image => nil).find_each do |model|
      cover_image_prefix = "uploads/user/cover_image/#{model.id}/"
      bucket.objects.with_prefix(cover_image_prefix).each do |obj|
        ext = obj.key.split('.').last
        new_name = if obj.key =~ /\/cropped_/
          "#{model.cover_image_token}_cropped_#{model.cover_image.send(:crop_args).join('_')}"
        else
          model.cover_image_token
        end
        new_name = "#{cover_image_prefix}#{new_name}.#{ext}"
        puts "\t[#{model.id}] Moving #{obj.key} to #{new_name}"
        obj.move_to new_name, :acl => :public_read, :cache_control => 'public, max-age=315576000', :content_type => obj.content_type
        model.save
      end
    end
    
    # puts "\n\nUpdating pins"
    # Pin.where.not(:image => nil).find_each do |model|
    #   image_prefix = "uploads/pin/image/#{model.id}/"
    #   bucket.objects.with_prefix(image_prefix).each do |obj|
    #     ext = obj.key.split('.').last
    #     new_name = "#{image_prefix}#{model.image_token}.#{ext}"
    #     puts "\t[#{model.id}] Moving #{obj.key} to #{new_name}"
    #     obj.move_to new_name, :acl => :public_read, :cache_control => 'public, max-age=315576000', :content_type => obj.content_type
    #   end
    #   model.save
    # end
    
    puts "\n\nDone processing."
  end
  
end