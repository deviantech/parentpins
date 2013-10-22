CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => AMAZON[:key],
    :aws_secret_access_key  => AMAZON[:secret],
    # :host                   => 's3.example.com',             # optional, defaults to nil
    # :endpoint               => 'https://s3.example.com:8080' # optional, defaults to nil
  }
  config.fog_directory  = CARRIERWAVE[:bucket]
  config.fog_attributes = {'Cache-Control' => 'max-age=315576000'}  # optional, defaults to {}
end
