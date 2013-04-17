namespace :trends do
  
  namespace :update do

    desc "Update the trending calculations for pins"
    task :pins => :environment do
      max_to_process = 1_000    # Only sort the most recent 1,000 (limit memory usage)
      points = {}
          
      pins = Pin.limit(max_to_process).order('id DESC').select([:id, :repins_count, :created_at, :uuid])
      pins.each do |p|
        p.update_attribute :trend_position, p.likes_count + p.repins_count + trend_points_for_creation_date(p)
      end

      # All other pins get identical trend_position
      Pin.update_all ['trend_position = ?', 0], ['id < ?', pins.last.id]
    end
    
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



# TODO: remove this whole namespace (or use in dev only) once we get some real users
namespace :fake do

  desc "Randomize created_at date on all pins (sometime between their board's creation date and now)"
  task :randomize_pins => :environment do
    Pin.includes(:board).find_each do |p|
      first  = p.board.created_at
      last   = Time.now
      new_creation = Time.at((last.to_f - first.to_f) * rand + first.to_f)
      p.update_attribute(:created_at, new_creation)
      p.update_attribute(:updated_at, new_creation) if p.updated_at < p.created_at
    end
  end
  
end

