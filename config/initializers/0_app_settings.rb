AUTH = {
  facebook: {
    key: ENV["FB_#{Rails.env.production? ? 'PROD' : 'DEV'}_KEY"],
    secret: ENV["FB_#{Rails.env.production? ? 'PROD' : 'DEV'}_SECRET"],
  }
}.with_indifferent_access

AMAZON = {
  key: ENV['AMAZON_KEY'],
  secret: ENV['AMAZON_SECRET']
}.with_indifferent_access

CARRIERWAVE = YAML.load_file( File.join(Rails.root, 'config', 'carrierwave.yml') ).with_indifferent_access[Rails.env]
AFFILIATES = YAML.load_file( File.join(Rails.root, 'config', 'affiliates.yml')).with_indifferent_access

# Remove the "|| true" when Christy done testing emails
ALLOW_MAIL_PREVIEW = Rails.env.development? || true
