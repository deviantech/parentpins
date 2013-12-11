# encoding: utf-8

class PinImageUploader < BaseUploader
  include CarrierWave::Meta
  include ::CarrierWave::Backgrounder::Delay
  
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

  def store_average_color
    cache! unless File.exists?(current_path) # Allows use with remote, previously-uploaded files (e.g. collecting meta on existing files)
    
    cmd = %{convert "#{current_path.shellescape}" -colorspace rgb -scale 1x1 -format "%[pixel:p{0,0}]" info:}
    sub = Subexec.run(cmd, :timeout => 15) # Using subexec because minimagick commands sometimes stall without returning control
    
    return true unless sub.exitstatus == 0 && matched = sub.output.match(/\((.+?)\)/)
    hex = matched[1].split(',').inject('') {|str, component| str += component.to_i.to_s(16)}
    model.image_average_color = hex
  end
  
end

__END__
# To get an instance to work with:
img = ::MiniMagick::Image.open(current_path)