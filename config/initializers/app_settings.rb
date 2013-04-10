
# Remove the "|| true" when Christy done testing emails
ALLOW_MAIL_PREVIEW = Rails.env.development? || true


# It took WAY too long to figure this out, but if you want to include helpers in the .erb sprockets context, put 'em in here
module Sprockets
  module Helpers
    module RailsHelper
      include BookmarkletHelper
      
      #  Any other custom helper methods go here
      
    end
  end
end