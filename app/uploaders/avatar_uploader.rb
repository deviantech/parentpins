# encoding: utf-8
class AvatarUploader < BaseUploader

  version :main do
    process :crop_to => [120, 120]

    def full_filename(file = model.avatar.file)
      custom_filename(file, :cropping => true)
    end
  end
  
  version :v50, :from_version => :main do
    process :resize_to_fill => [50, 50]
  end  

  version :v30, :from_version => :v50 do
    process :resize_to_fill => [30, 30]
  end
    
end
