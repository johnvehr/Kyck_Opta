module Opta
  module Handlers
    class F1TeamUpdate < Opta::BaseHandler
      include Opta::Handlers::Common::F1Common
      set_priority 5

      def process

        league = League.find_or_create_by_opta_id_and_name! int_from(document['competition_id']), document['competition_name']
        raise Opta::HandlerException "Failed to find or create league" unless league

        hash_teams = document['Team']
        hash_teams.each do |team_hash|
          ref = team_hash['uID']
          name = team_hash['Name'][0]

          Rails.logger.debug("find or create team using name '#{name}' in league '#{league.name}'")
          team = Team.find_or_create_by_opta_id_and_name! int_from(ref), name, league
          team.league = league
          team.save!
        end
      end
    end
  end
end
