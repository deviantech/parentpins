HOST = if Rails.env.production?  then 'www.parentpins.com'
    elsif Rails.env.staging?     then 'staging.parentpins.com'
    else                              'localhost:3000'
    end