# encoding: utf-8
class AvatarUploader < BaseUploader

  # No gifs -- kinda crops animated OK, but just gets confusing and I don't want to hassle with reformating
  def extension_white_list
    %w(jpg jpeg png)
  end
  

  version :main do
    process :crop_to => [120, 120]

    def full_filename(file = model.avatar.file)
      custom_filename(file, :cropping => true)
    end
  end
  
  version :v50, :from_version => :main do
    process :resize_to_fill => [50, 50]

    def full_filename(file = model.avatar.file)
      custom_filename(file, :cropping => true, :version => :v50)
    end
  end  

  version :v30, :from_version => :v50 do
    process :resize_to_fill => [30, 30]
    
    def full_filename(file = model.avatar.file)
      custom_filename(file, :cropping => true, :version => :v30)
    end
  end
    
end
