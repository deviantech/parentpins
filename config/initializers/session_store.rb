# Be sure to restart your server when you modify this file.

# Explicitly sharing cookies across subdomains in production
domain = case Rails.env
when 'production' then '.parentpins.com'
when 'staging'    then 'staging.parentpins.com'
else :all
end

# Using different session cookie names so staging cookie doesn't conflict with production when sharing subdomains
key = "_pins_#{Rails.env.production? ? '' : Rails.env}_session"

ParentPins::Application.config.session_store :cookie_store, :key => key, :domain => domain