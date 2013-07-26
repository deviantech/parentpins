require 'fileutils'
class SetSomeValueForExistingSourceUrls < ActiveRecord::Migration
  def up
    # Skip unless we have images that need changing, or we're no longer storing in filesystem
    return true unless Pin.with_image.first.try(:image).try(:path).match('public/uploads')
    
    # Set SOME value, so old pins still show up in search results
    Pin.find_each do |p|
      next unless p.source_url.blank?
      p.update_attribute :source_url, "OLD:#{p.image_filename}"
    end

    def to_shared(path)
      path.to_s.gsub(/\/releases\/\d+?\/public\//, '/shared/')
    end
    
    # MOVE existing files to better location
    Pin.find_each do |p|
      newpath = to_shared(p.image.path)
      next if newpath.blank? || File.exists?(newpath)
      
      newname = File.basename(newpath)
      dir = File.dirname(newpath)
      oldname = Dir.entries(dir).detect {|f| !f.starts_with?('.') && !f.starts_with?(/v\d\d\d?_/)}
      
      Dir.entries(dir).each do |f|
        next if f.starts_with?('.')
        next unless f.match(oldname)
        
        current_path = File.join(dir, f)
        future_path = File.join(dir, f.gsub(oldname, newname))
        FileUtils.move to_shared(current_path), to_shared(future_path)
      end
    end    
  end

  def down
  end
end
