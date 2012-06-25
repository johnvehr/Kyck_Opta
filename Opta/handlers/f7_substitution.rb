module Opta
  module Handlers
    class F7Substitution < Opta::BaseHandler
      include Opta::Handlers::Common::F7Common

      def process
        return unless need_to_process

        if self.prev_hash

          new_substitutions = teamdata_diff_elements 'Substitution'

          new_substitutions.each do |s|
            post s.element, s.team
          end

        end
      end

      def post substitution, team
        player_from_ref = substitution['SubOff']
        player_to_ref = substitution['SubOn']
        team_ref = team['TeamRef']
        team_tag = build_team_tag(team_ref)

        return if team_tag.nil?
        player_from_tag = build_player_tag(player_from_ref)
        player_to_tag = build_player_tag(player_to_ref)

        if substitution['Reason'] == 'Injury'
          message = I18n.t("opta.f7.injury",
                           :team => team_name(team_ref),
                           :shirt_number => shirt_number(player_from_ref,team),
                           :name => player_name(player_from_ref, team_ref),
                           :replaced_by => player_name(player_to_ref, team_ref),
                           :minute => substitution['Time']
          )

          post = create_post message, 'Injuries', [player_from_tag, player_to_tag, team_tag , build_match_tag]
          Reshare.injury(
            post,
            :player_in => player_to_tag.owner,
            :player_out => player_from_tag.owner, 
            :team => team_tag.owner
          )
        else
          message = I18n.t("opta.f7.substitution",
                           :team => team_name(team_ref),
                           :shirt_number_from => shirt_number(player_from_ref,team),
                           :name_from => player_name(player_from_ref, team_ref),
                           :shirt_number_to => shirt_number(player_to_ref, team),
                           :name_to => player_name(player_to_ref, team_ref),
                           :minute => substitution['Time']
        )

          post = create_post message, 'Subs', [player_from_tag, player_to_tag, team_tag, build_match_tag]
        end
      end

    end
  end
end
