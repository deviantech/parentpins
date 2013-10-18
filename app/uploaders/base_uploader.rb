# encoding: utf-8

require 'carrierwave/processing/mime_types'

class BaseUploader < CarrierWave::Uploader::Base  
  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::Vips
  include CarrierWave::MiniMagick
  include CarrierWave::MimeTypes
  include Piet::CarrierWaveExtension
  process :set_content_type
  process :fix_exif_rotation
  process :strip
  
  # TODO: run piet gem's optimizations via resque eventually - https://github.com/albertbellonch/piet
  # process :optimize

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end
  
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    ActionController::Base.helpers.asset_path("fallback/#{model.class.to_s.underscore}_#{mounted_as}/" + [version_name, "default.jpg"].compact.join('_'))
  end
  
  
  
  # Rotates the image based on the EXIF Orientation (not defined in Vips)
  def fix_exif_rotation
    manipulate! do |img|
      img.auto_orient if img.respond_to?(:auto_orient)
      img = yield(img) if block_given?
      img
    end
  end

  # Strips out all embedded information from the image
  def strip
    manipulate! do |img|
      img.strip
      img = yield(img) if block_given?
      img
    end
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
  
  def crop_args
    %w(x y w h).map { |accessor| model.send("#{mounted_as}_#{accessor}").to_i }
  end
  
  
end