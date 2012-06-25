module Opta
  module Handlers
    class F7TeamUpdate < Opta::BaseHandler
      include Opta::Handlers::Common::F7Common

      set_priority 4

      def process

        if period == 'PreMatch' || period_become('FirstHalf') || self.prev_hash.blank?

          league = League.find_or_create_by_opta_id_and_name! int_from(document['Competition'][0]['uID']), document['Competition'][0]['Name'][0]
          raise Opta::HandlerException "Failed to find or create league" unless league

          hash_teams = document['Team']
          hash_teams.each do |team_hash|
            ref = team_hash['uID']
            name = team_hash['Name'][0]

            team = Team.find_or_create_by_opta_id_and_name! int_from(ref), name, league
            team.save
            return if team_hash['Player'].nil?
            team_hash['Player'].each do |px|
              name = player_name px['uID'], ref
              player = Player.find_or_create_by_opta_id_and_name! int_from(px['uID']), name
              player.position = px['Position'][0] if px['Postion'].present?
              player.team = team
              player.save!
            end

          end
        end
      end

    end
  end
end
