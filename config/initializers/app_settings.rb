


# It took WAY too long to figure this out, but if you want to include helpers in the .erb sprockets context, put 'em in here
module Sprockets
  module Helpers
    module RailsHelper
      include BookmarkletHelper
    end
  end
end