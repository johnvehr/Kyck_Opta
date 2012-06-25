module Opta
  module Handlers
    module Common
      module FeedCommon
        extend ActiveSupport::Concern

        def int_from s
          s.gsub(/\D/, '').to_i
        end

        def document
          self.hash['SoccerDocument'][0]
        end

      end
    end
  end
end
