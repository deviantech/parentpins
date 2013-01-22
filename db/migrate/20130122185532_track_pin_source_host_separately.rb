class TrackPinSourceHostSeparately < ActiveRecord::Migration
  def up
    add_column :pins, :domain, :string
    Pin.reset_column_information
    Pin.find_each do |p|
      uri = begin
        URI.parse(p.url.to_s)
      rescue; nil;
      end
      p.domain = uri.try(:host)
      p.save
    end
  end

  def down
    remove_column :pins, :domain, :string
  end
end