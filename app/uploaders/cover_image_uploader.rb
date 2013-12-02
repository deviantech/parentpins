# encoding: utf-8
class CoverImageUploader < BaseUploader

  version :cropped do
    process :crop_to => [1020, 160]

    def full_filename(file = model.cover_image.file)
      custom_filename(file, :cropping => true)
    end
  end
  
end
