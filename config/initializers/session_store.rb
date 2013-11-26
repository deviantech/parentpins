# Be sure to restart your server when you modify this file.

domain = case Rails.env
when 'production' then '.parentpins.com'
when 'staging'    then 'staging.parentpins.com'
else :all
end

ParentPins::Application.config.session_store :cookie_store, :key => '_pins_session', :domain => domain