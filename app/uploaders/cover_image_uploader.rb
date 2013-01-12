# encoding: utf-8
class CoverImageUploader < BaseUploader
  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  process :resize_to_fill => [1020, 160]
end
