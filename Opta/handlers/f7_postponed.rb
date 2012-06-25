module Opta
  module Handlers
    class F7Postponed < Opta::BaseHandler
      include Opta::Handlers::Common::F7Common

      def process
        return unless need_to_process

        if game_result_become('Postponed')
          team1_tag = build_team_tag(team_name_by_index(0))
          team2_tag = build_team_tag(team_name_by_index(1))

          return if team1_tag.nil? && team2_tag.nil?

          message = I18n.t("opta.f7.postponed",
                           :team1 => team_name_by_index(0),
                           :team2 => team_name_by_index(1)
                        )

          post = create_post message, 'Postponed', [team1_tag, team2_tag, build_match_tag]
          Reshare.postponed(
            post,
            :team1 => team1_tag.owner,
            :team2 => team2_tag.owner
          )
        end

      end
    end
  end
end
