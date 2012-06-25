module Opta
  class Worker
    @queue = $OPTA_QUEUE || "opta_other"

    def self.perform(args = {})
      stat = RawStat.find args["id"]
      manager = Opta::FeedManager.new args["feed_type"]
      manager.process stat
    end
  end
end
