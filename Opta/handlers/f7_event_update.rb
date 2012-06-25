module Opta
  module Handlers
    class F7EventUpdate < Opta::BaseHandler
      include Opta::Handlers::Common::F7Common

      set_priority 5

      def process

        if period_become('PreMatch') || self.prev_hash.blank?
          opta_id = game_id
          team1 = Team.find_by_opta_id(int_from(document['MatchData'][0]['TeamData'][0]['TeamRef']))
          team2 = Team.find_by_opta_id(int_from(document['MatchData'][0]['TeamData'][1]['TeamRef']))
          starting_at = DateTime.parse(document['MatchData'][0]['MatchInfo'][0]['Date'][0])

          Event.find_or_create_by_opta_id_and_team1_and_team2_and_starting_at! opta_id, team1, team2, starting_at
        end
        if get_venue_name
          Location.find_or_create_by_opta_id(get_venue_id, get_venue_name, get_venue_country)
        end
      end

    end
  end
end
