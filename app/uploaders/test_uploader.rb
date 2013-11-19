class TestUploader < BaseUploader
  
  def store_dir
    "#{Rails.root}/tmp/testing"
  end
  
end

__END__
todo: auto rename extensions in the gem, since filename is called before contentype checked at this point

u=TestUploader.new
f=File.open('/Users/kali/Desktop/Sample Files/_actually_jpg.png')
u.store! f
