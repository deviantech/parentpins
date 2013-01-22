HOST = if Rails.env.production?  then 'www.parentpins.com'
    elsif Rails.env.staging?     then 'staging.parentpins.com'
    else                              'localhost:3000'
    end

NUM_BACKGROUND_IMAGES = Dir.entries( File.join(Rails.root, 'app', 'assets', 'images', 'backgrounds') ).grep(/jpg/).count