class EnlargePinThumbnails < ActiveRecord::Migration

  def change
    Pin.find_each do |pin|
      next unless pin.image?
      pin.image.recreate_versions!
    end
  end
  
end
