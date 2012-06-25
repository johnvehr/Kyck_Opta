module Opta
  module Handlers
    class F40PlayerUpdate < Opta::BaseHandler
      include Opta::Handlers::Common::F40Common

      def process

        league = League.find_or_create_by_opta_id_and_name! int_from(document['competition_id']), document['competition_name']
        raise Opta::HandlerException "Failed to find or create league" unless league

        hash_teams = document['Team']
        hash_teams.each do |team_hash|
          ref = team_hash['uID']
          name = team_hash['Name'][0]

          team = Team.find_or_create_by_opta_id_and_name! int_from(ref), name, league
          team.league = league

          stadium_name = team_hash['Stadium'][0]['Name'][0] rescue nil
          team.stadium_location = Location.find_or_create_by_name(stadium_name) if stadium_name
          team.save!

          #OPTA sends other info here, like Trainer.
          next if team_hash['Player'].nil?

          team_hash['Player'].each do |px|
            player = Player.find_or_create_by_opta_id_and_name! int_from(px['uID']), px['Name'][0]
            player.position = px['Position'][0]
            player.jersey_num = value_from_list(px['Stat'], 'jersey_num')
            player.team = team
            player.save!
          end
        end
      end
    end
  end
end
