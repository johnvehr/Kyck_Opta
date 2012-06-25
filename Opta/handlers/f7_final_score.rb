module Opta
  module Handlers
    class F7FinalScore < Opta::BaseHandler
      include Opta::Handlers::Common::F7Common

      def process
        return unless need_to_process

        if period_become('FullTime')
          teams = teams_with_goals

          translation = 'defeated'
          if teams[0][:goals] == teams[1][:goals]
            translation = 'draws'
          elsif teams[1][:goals] > teams[0][:goals]
            teams.reverse!
          end

          message = I18n.t("opta.f7.finalscore.#{translation}",
                           :team1 => teams[0][:name],
                           :team2 => teams[1][:name],
                           :score1 => teams[0][:goals],
                           :score2 => teams[1][:goals],
                           :venue => get_venue_name
                        )
          team1_tag = build_team_tag(teams[0][:ref])
          team2_tag = build_team_tag(teams[1][:ref])

          return if team1_tag.nil? && team2_tag.nil?
          post = create_post message, 'Scores', [team1_tag, team2_tag , build_match_tag]

          Reshare.final_score(
            post,
            :team1 => team1_tag.owner,
            :team2 => team2_tag.owner
          )

          update_event_teams_scores teams, true
        end
      end

    end
  end
end
