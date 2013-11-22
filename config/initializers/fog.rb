CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => AMAZON[:key],
    :aws_secret_access_key  => AMAZON[:secret],
  }
  config.fog_directory  = CARRIERWAVE[:bucket]
  config.fog_attributes = {'Cache-Control' => 'max-age=315576000'}  # optional, defaults to {}
end
