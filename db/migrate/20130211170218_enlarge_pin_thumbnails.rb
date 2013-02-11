class EnlargePinThumbnails < ActiveRecord::Migration

  def change
    Pin.find_each do |pin|
      next unless pin.image?
      puts "Reprocessing images for pin #{pin.id}"
      pin.image.recreate_versions!
    end
  end
  
end
