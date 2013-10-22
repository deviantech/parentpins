# encoding: utf-8
class CoverImageUploader < BaseUploader

  version :cropped do
    process :crop_to => [1020, 160]
  end
  
end
