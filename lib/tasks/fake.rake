namespace :pins do

  desc "Randomize created_at date on all pins (sometime between their board's creation date and now)"
  task :randomize => :environment do
    Pin.includes(:board).find_each do |p|
      first  = p.board.created_at
      last   = Time.now
      new_creation = Time.at((last.to_f - first.to_f) * rand + first.to_f)
      p.update_attribute(:created_at, new_creation)
      p.update_attribute(:updated_at, new_creation) if p.updated_at < p.created_at
    end
  end
  
end