if Rails.env.production? || Rails.env.staging?
  Bugsnag.configure do |config|
    config.api_key = "54fa9ef1761a0d2c1fcdc1c063081847"
  end
end