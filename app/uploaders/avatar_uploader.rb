# encoding: utf-8
class AvatarUploader < BaseUploader

  version :main do
    process :crop_to => [120, 120]
  end
  
  version :v50, :from_version => :main do
    process :resize_to_fill => [50, 50]
  end  

  version :v30, :from_version => :v50 do
    process :resize_to_fill => [30, 30]
  end
  
  
  def filename 
    # OK to use model.id, because avatar never created before user record is created
    # BUT, means next avatar upload will always have same filename. Weird for caching?
    return super unless file
    @name ||= Digest::MD5.hexdigest("#{model.class.name}.#{model.id}")
    "#{@name}.#{file.extension}"
  end
  
end
