module Opta
  module Handlers
    module Common
      module F40Common
        extend ActiveSupport::Concern
        include Opta::Handlers::Common::FeedCommon

        def value_from_list list, attr
          list.each do |el|
            return el['content'] if el['Type'] == attr
          end
          nil
        end

      end
    end
  end
end
