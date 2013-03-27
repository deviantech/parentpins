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
  # process :optimize

  # Include the Sprockets helpers for Rails 3.1+ asset pipeline compatibility:
  include Sprockets::Helpers::RailsHelper
  include Sprockets::Helpers::IsolatedHelper  

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def filename
    return super unless model.class.name == 'User' && file
    
    # OK to use model.id, because avatar never created before user record is created
    @name ||= Digest::MD5.hexdigest("#{model.class.name}.#{model.id}")
    "#{@name}.#{file.extension}"
  end
  
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # For Rails 3.1+ asset pipeline compatibility:
    asset_path("fallback/#{model.class.to_s.underscore}_#{mounted_as}/" + [version_name, "default.jpg"].compact.join('_'))
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
  
end