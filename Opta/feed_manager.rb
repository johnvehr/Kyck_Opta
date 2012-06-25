module Opta
  class FeedManager

    def initialize doc_type
      @doc_type = doc_type
    end

    def process raw_stat
      handlers_classes = [
          :F7TeamUpdate, :F7EventUpdate, :F7StarterPlayers, :F7StarterTeam, :F7Goal, :F7Substitution, :F7HalftimeScore,
          :F7FinalScore, :F7Cards, :F7ShootoutBegins, :F7Overtime, :F7Postponed,
          :F40PlayerUpdate,
          :F1EventUpdate, :F1TeamUpdate
      ]

      hash = XmlSimple.xml_in(raw_stat.raw_post)

      prev_hash = nil

      if raw_stat.feed_type == 'F7'
        prev_stat = RawStat.where(:feed_type => 'F7', :game_id => raw_stat.game_id).order("created_at desc").offset(1).take(1).first rescue nil
        prev_hash = XmlSimple.xml_in(prev_stat.raw_post) rescue nil
        period = hash['SoccerDocument'][0]['MatchData'][0]['MatchInfo'][0]['Period'] rescue nil
        if period
          raw_stat.update_attribute(:period, period)
        end
      end

      handlers = []
      handlers_classes.each do |clazz|
        if clazz.to_s.include?(@doc_type)
          handlers << (Opta::Handlers.const_get clazz).new(raw_stat.game_id, hash, prev_hash)
        end
      end
      handlers.sort_by { |o| o.priority}.each do
        |h| h.process
      end
    end

  end
end