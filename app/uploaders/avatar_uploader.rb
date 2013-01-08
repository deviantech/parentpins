# encoding: utf-8
class AvatarUploader < BaseUploader
  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  process :resize_to_fill => [120, 120]

  version :v30 do
    process :resize_to_fill => [30, 30]
  end
  
  version :v50 do
    process :resize_to_fill => [50, 50]
  end  
end
