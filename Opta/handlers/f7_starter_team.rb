module Opta
  module Handlers
    class F7StarterTeam < Opta::BaseHandler
      include Opta::Handlers::Common::F7Common

      def process
        return #unless need_to_process

        if period_become('PreMatch')
          team1_tag = build_team_tag(team_ref_by_index(0))
          team2_tag = build_team_tag(team_ref_by_index(1))

          return if team1_tag.nil? && team2_tag.nil?

          message = I18n.t("opta.f7.starter_team",
                           :team1 => team_name_by_index(0),
                           :team2 => team_name_by_index(1),
                           :venue => get_venue_name
                        )
          post = create_post message, 'Starters', [team1_tag, team2_tag, build_match_tag]
          Reshare.starter_teams(post, :team1 => team1_tag.owner, :team2 => team2_tag.owner)

        end

      end
    end
  end
end
