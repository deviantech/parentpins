# encoding: utf-8

class PinImageUploader < BaseUploader

  process :resize_to_limit => [500, 99999]

  version :v192 do
    process :resize_to_limit => [192, 99999]
  end

  # Used for board thumbs
  version :v55 do
    process :resize_to_fill => [55, 55]
  end
  
  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

end
