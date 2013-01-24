
NUM_BACKGROUND_IMAGES = Dir.entries( File.join(Rails.root, 'app', 'assets', 'images', 'backgrounds') ).grep(/jpg/).count

HOST = ActionMailer::Base.default_url_options[:host]