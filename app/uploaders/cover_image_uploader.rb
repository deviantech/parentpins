# encoding: utf-8
class CoverImageUploader < BaseUploader
  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  version :cropped do
    process :crop_to => [1020, 160]
  end
  
end
