# encoding: utf-8

class BoardCoverUploader < BaseUploader

  process :resize_to_fill => [222, 150]
  
  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog
end
