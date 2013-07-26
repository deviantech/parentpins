# encoding: utf-8

class PinImageUploader < BaseUploader

  process :resize_to_limit => [520, 99999]

  version :v222 do
    process :resize_to_limit => [222, 99999]
  end

  # Used for board thumbs
  version :v55, :from_version => :v222 do
    process :resize_to_fill => [55, 55]
  end
  
  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog
  
  def filename
    return super unless file
    "#{secure_token}.#{file.extension}"
  end
  
  protected
  
  def secure_token
    model.uuid || SecureRandom.uuid
  end

end
