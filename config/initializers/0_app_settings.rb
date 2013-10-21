# Various auth files
AUTH = YAML.load_file( File.join(Rails.root, 'config', 'auth.yml') ).with_indifferent_access[Rails.env]
AMAZON = YAML.load_file( File.join(Rails.root, 'config', 'amazon.yml') ).with_indifferent_access
CARRIERWAVE = YAML.load_file( File.join(Rails.root, 'config', 'carrierwave.yml') ).with_indifferent_access[Rails.env]
AFFILIATES = YAML.load_file( File.join(Rails.root, 'config', 'affiliates.yml')).with_indifferent_access

# Remove the "|| true" when Christy done testing emails
ALLOW_MAIL_PREVIEW = Rails.env.development? || true
