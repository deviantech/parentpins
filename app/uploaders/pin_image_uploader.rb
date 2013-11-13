# encoding: utf-8

class PinImageUploader < BaseUploader
  include CarrierWave::Meta
  
  process :resize_to_limit => [520, 99999]

  version :v222 do
    process :resize_to_limit => [222, 99999]
    process :store_meta
    process :store_average_color
  end

  # Used for board thumbs
  version :v55, :from_version => :v222 do
    process :resize_to_fill => [55, 55]
  end
  
  
  protected

  # e.g. convert test.jpg -colorspace rgb -scale 1x1 -format "%[pixel:p{0,0}]" info  
  def store_average_color
    cache! unless File.exists?(current_path) # Allows use with remote, previously-uploaded files (e.g. collecting meta on existing files)
    
    img = ::MiniMagick::Image.open(current_path)
    img.combine_options do |c|
      c.colorspace "rgb"
      c.scale "1x1"
    end
    color = img['%[pixel:p{0,0}]'] # e.g. "srgb(112,101,99)"
    hex = color.match(/\((.+?)\)/)[1].split(',').inject('') {|str, component| str += component.to_i.to_s(16)}
    model.image_average_color = hex
  end
  
end