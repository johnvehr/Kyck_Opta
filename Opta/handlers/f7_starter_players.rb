module Opta
  module Handlers
    class F7StarterPlayers < Opta::BaseHandler
      include Opta::Handlers::Common::F7Common

      set_priority 6

      def process
        return unless need_to_process

        if period_become('PreMatch') || period_become('FirstHalf') || self.prev_hash.blank?

          event = Event.where(:opta_id => game_id).first
          document['MatchData'][0]['TeamData'].each do |team_data|
            team = Team.where(:opta_id => int_from(team_data['TeamRef']), :kind => "system").first
            return if team.nil?

            team_data['PlayerLineUp'][0]['MatchPlayer'].each do |match_player|
              player_ref = int_from(match_player['PlayerRef'])
              player = Player.where(:opta_id => player_ref).first

              starter = Event::Starter.find_or_create_by_event_and_team_and_player event, team, player
              starter.position = match_player['Position'].downcase.to_sym
              starter.shirt_number = match_player['ShirtNumber'].to_i
            end

          end
        end

      end
    end
  end
end
