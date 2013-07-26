class KeepDigestOfOriginalImageSourceUrl < ActiveRecord::Migration
  def up
    add_column :pins, :source_url, :string
    Pin.reset_column_information
    Pin.find_each do |p|
      next unless p.source_url.blank?
      
      src = File.basename(p.image.path.to_s).to_s
      src = src.length > 1 ? src : "pin-#{p.id}-source"
      p.update_attribute :source_url, "OLD:#{src}"
    end
  end

  def down
    remove_column :pins, :source_url
  end
end