
NUM_BACKGROUND_IMAGES = Dir.entries( File.join(Rails.root, 'app', 'assets', 'images', 'backgrounds') ).grep(/jpg/).count