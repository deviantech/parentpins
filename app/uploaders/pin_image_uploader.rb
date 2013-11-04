# encoding: utf-8

class PinImageUploader < BaseUploader
  include CarrierWave::Meta
  
  process :resize_to_limit => [520, 99999]

  version :v222 do
    process :resize_to_limit => [222, 99999]
    process :store_meta
  end

  # Used for board thumbs
  version :v55, :from_version => :v222 do
    process :resize_to_fill => [55, 55]
  end
  
end