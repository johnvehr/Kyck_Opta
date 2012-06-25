module Opta
  module Handlers
    class F7Overtime < Opta::BaseHandler
      include Opta::Handlers::Common::F7Common

      def process
        return unless need_to_process

        if period_become('ExtraFirstHalf') || period_become('ExtraSecondHalf')
          teams = teams_with_goals

          team1_tag = build_team_tag(teams[0][:ref])
          team2_tag = build_team_tag(teams[1][:ref])

          return if team1_tag.nil? && team2_tag.nil?

          message = I18n.t("opta.f7.overtime",
                           :team1 => teams[0][:name],
                           :team2 => teams[1][:name],
                           :team1_score => teams[0][:goals],
                           :team2_score => teams[1][:goals]
                        )

          post = create_post message, 'Overtime', [team1_tag, team2_tag, build_match_tag]
          Reshare.overtime(
            post,
            :team1 => team1_tag.owner,
            :team2 => team2_tag.owner
          )
        end

      end
    end
  end
end
