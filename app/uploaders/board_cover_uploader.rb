# encoding: utf-8

class BoardCoverUploader < BaseUploader
  process :resize_to_fill => [222, 150]  
end
