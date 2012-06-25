module Opta
  module Handlers
    module Common
      module F1Common
        extend ActiveSupport::Concern
        include Opta::Handlers::Common::FeedCommon
      end
    end
  end
end
