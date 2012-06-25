module Opta
  module Handlers
    class F1EventUpdate < Opta::BaseHandler
      include Opta::Handlers::Common::F1Common

      def process

        document['MatchData'].each do |match_data|
          opta_id = int_from(match_data['uID'])
          team1 = Team.find_by_opta_id(int_from(match_data['TeamData'][0]['TeamRef']))
          team2 = Team.find_by_opta_id(int_from(match_data['TeamData'][1]['TeamRef']))
          timezone = match_data['MatchInfo'][0]['TZ'][0]
          full_date_string = [match_data['MatchInfo'][0]['Date'][0], timezone].join(' ')
          starting_at = DateTime.parse(full_date_string).utc
          Rails.logger.info "** OPTA: Creating event #{opta_id} for teams #{team1}, #{team2}"
          Rails.logger.info "** OPTA: Event time: #{full_date_string}"

          event = Event.find_or_create_by_opta_id_and_team1_and_team2_and_starting_at! opta_id, team1, team2, starting_at

          if event
            event.team1_score = match_data['TeamData'][0]['Score']
            event.team2_score = match_data['TeamData'][1]['Score']
            event.save!
          end
        end

      end

    end
  end
end
