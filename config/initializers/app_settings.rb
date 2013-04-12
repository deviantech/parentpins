
# Remove the "|| true" when Christy done testing emails
ALLOW_MAIL_PREVIEW = Rails.env.development? || true

AFFILIATES = YAML.load_file( File.join(Rails.root, 'config', 'affiliates.yml')).with_indifferent_access


# It took WAY too long to figure this out, but if you want to include helpers in the .erb sprockets context, put 'em in here
module Sprockets
  module Helpers
    module RailsHelper
      
      # Any other custom helper methods go here
      # TODO: this no longer works (maybe with rails 3.2.13 upgrade?)
      # Edited assets to not require any custom methods, but eventually we might need to revisit if our needs change
      
    end
  end
end