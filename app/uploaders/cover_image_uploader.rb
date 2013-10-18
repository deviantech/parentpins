# encoding: utf-8
class CoverImageUploader < BaseUploader
  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  version :cropped do
    process :crop_to => [1020, 160]
  end
  
  # Here down based mostly on https://github.com/gzigzigzeo/carrierwave-meta#integrating-carrierwave-with-jcrop
  
  # Crop processor
  def crop_to(width, height)
    # Checks that crop area is defined and crop should be done.
    if ((crop_args[0] == crop_args[2]) || (crop_args[1] == crop_args[3]))
      # If not creates default image and saves it's dimensions.
      resize_to_fill_and_save_dimensions(width, height)
    else
      args = crop_args + [width, height]
      crop_and_resize(*args)
    end
  end

  def crop_and_resize(x, y, w, h, new_width, new_height)
    manipulate! do |img|
      img.crop("#{w}x#{h}+#{x}+#{y}")
      img
    end
    resize_to_fill(new_width, new_height)
  end

  # Creates the default crop image.
  # Here the original crop area dimensions are restored and assigned to the model's instance.
  def resize_to_fill_and_save_dimensions(new_width, new_height)
    img = ::MiniMagick::Image.from_file(current_path)
    width, height = img.columns, img.rows
    
    resize_to_fill(new_width, new_height)

    w_ratio = width.to_f / new_width.to_f
    h_ratio = height.to_f / new_height.to_f

    ratio = [w_ratio, h_ratio].min

    model.cover_image_w = ratio * new_width
    model.cover_image_h = ratio * new_height
    model.cover_image_x = (width - model.crop_w) / 2
    model.cover_image_y = (height - model.crop_h) / 2
  end

  private
  
  def crop_args
    %w(x y w h).map { |accessor| model.send("cover_image_#{accessor}").to_i }
  end
  
end
