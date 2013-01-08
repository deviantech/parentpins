# encoding: utf-8

class PinImageUploader < BaseUploader

  process :resize_to_limit => [500, 99999]

  version :v320 do
    process :resize_to_limit => [320, 99999]
  end
  
  version :v192 do
    process :resize_to_limit => [192, 99999]
  end
  
  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

end
