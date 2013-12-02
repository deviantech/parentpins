# encoding: utf-8

class BaseUploader < CarrierWave::Uploader::Base  
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::Vips
  include CarrierWave::MiniMagick
  include CarrierWave::MimetypeFu
  
  include Piet::CarrierWaveExtension
  
  process :strip
  
  # TODO: run piet gem's optimizations via resque eventually - https://github.com/albertbellonch/piet
  # process :optimize
  
  # Add a white list of extensions which are allowed to be uploaded. Processed after CarrierWave::MimetypeFu does it's magic, so extension actually matches real filetype.
  def extension_white_list
    %w(jpg jpeg gif png)
  end
  
  # Choose what kind of storage to use for this uploader:  
  storage Rails.env.production? || Rails.env.staging? ? :fog : :file
  # storage :fog
  
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  
  # Provide a default URL in case there hasn't been a file uploaded
  def default_url
    ActionController::Base.helpers.asset_path("fallback/#{model.class.to_s.underscore}_#{mounted_as}/" + [version_name, "default.jpg"].compact.join('_'))
  end
  
  # Only use HTTPS for remote image assets if the current page has been requested with HTTPS as well
  def url_with_conditional_ssl(*args)
    url_without_conditional_ssl(*args).sub(/\Ahttps?:/, '')
  end
  alias_method_chain :url, :conditional_ssl
  
  # Rotates based on the EXIF Orientation, then strips out all embedded information
  def strip
    manipulate! do |img|
      img.auto_orient if img.respond_to?(:auto_orient)
      img.strip
      img = yield(img) if block_given?
      img
    end
  end
  
  
  
  # Handle dynamic filenames.
  # If model has an [uploader]_token field, the files uploaded to that uploader will be randomly named.
  # If model has an [uploader]_original_filename field, the file's original name will be stored there.
  before :cache, :save_original_filename
  before :cache, :reset_uploader_token
  
  # Note that this will grab the filename after MimetypeFu magic has possibly changed the extension
  def save_original_filename(file)
    return true unless model.respond_to?("#{mounted_as}_original_filename")
    return true unless file.respond_to?(:original_filename)
    model.send("#{mounted_as}_original_filename=", file.original_filename)
  end
  
  def reset_uploader_token(file)
    return true if model.instance_variable_get("@regenerating_#{mounted_as}_thumbnails")
    return true unless model.respond_to?("#{mounted_as}_token=")
    model["#{mounted_as}_token"] = nil
  end
  
  def recreate_versions!
    model.instance_variable_set("@regenerating_#{mounted_as}_thumbnails", true)
    super
  end
  
  # Note: side effect - when new e.g. avatar uploaded, old files are removed properly EXCEPT CROPPED VERSIONS
  def custom_filename(file, opts = {})
    file = CarrierWave::SanitizedFile.new(file) if file.is_a?(String)
    base_name = model.respond_to?("#{mounted_as}_token") ? model.send("#{mounted_as}_token") : file.basename
    base_name = "#{base_name}_cropped_#{crop_args.join('_')}" if croppable? && opts[:cropping]
    [base_name, file.extension].join('.')
  end
  
  def filename
    custom_filename(file) if original_filename.present?
  end
    
  # Here down based mostly on https://github.com/gzigzigzeo/carrierwave-meta#integrating-carrierwave-with-jcrop
  
  # Crop processor
  def crop_to(width, height)
    # Checks that crop area is defined and crop should be done.
    if ((crop_args[0] == crop_args[2]) || (crop_args[1] == crop_args[3]))
      # If not creates default image and saves it's dimensions.
      resize_to_fill_and_save_dimensions(width, height)
    else
      args = crop_args + [width, height]
      crop_and_resize(*args)
    end
  end
  
  def crop_and_resize(x, y, w, h, new_width, new_height)
    manipulate! do |img|
      img.crop("#{w}x#{h}+#{x}+#{y}")
      img
    end
    resize_to_fill(new_width, new_height)
  end
  
  # Creates the default crop image.
  # Here the original crop area dimensions are restored and assigned to the model's instance.
  def resize_to_fill_and_save_dimensions(new_width, new_height)
    img = ::MiniMagick::Image.from_file(current_path)
    width, height = img['width'], img['height']
    
    resize_to_fill(new_width, new_height)
  
    w_ratio = width.to_f / new_width.to_f
    h_ratio = height.to_f / new_height.to_f
  
    ratio = [w_ratio, h_ratio].min
  
    model.send("#{mounted_as}_w=", ratio * new_width)
    model.send("#{mounted_as}_h=", ratio * new_height)
    model.send("#{mounted_as}_x=", (width - model.send("#{mounted_as}_w")) / 2)
    model.send("#{mounted_as}_y=", (height - model.send("#{mounted_as}_h")) / 2)
  end
  
  private
  
  def crop_keys
    @crop_keys ||= %w(x y w h).map {|accessor| "#{mounted_as}_#{accessor}" }
  end
  
  def croppable?
    crop_keys.all? {|accessor| model.respond_to?(accessor) }
  end
  
  def crop_args
    return nil unless croppable?
    crop_keys.map { |accessor| model.send(accessor).to_i }
  end
  
  
end
