module Opta
  module Handlers
    class F7Goal < Opta::BaseHandler
      include Opta::Handlers::Common::F7Common

      def process
        return unless need_to_process

        if self.prev_hash

          new_goals = teamdata_diff_elements 'Goal'

          new_goals.each do |g|
            if g.element['Type'] == 'Own'
              idx = g.team_index == 1 ? 0 : 1
              post g.element, team_by_index(idx), idx
            else
              post g.element, g.team, g.team_index
            end
          end

        end
      end

      def post goal, team, team_ind
        Rails.logger.info "*** OPTA: Goal #{goal} for #{team} at #{team_ind}"
        player_ref = goal['PlayerRef']
        team_ref = team['TeamRef']

        team_tag = build_team_tag(team_ref)
        return if team_tag.nil?

        teams = teams_with_goals
        player_tag = build_player_tag(player_ref)

        team_score = teams[team_ind][:goals]
        opponent_score = teams[1-team_ind][:goals]
        type = if team_score==opponent_score
                 "draws"
               elsif team_score > opponent_score
                 "leads"
               else
                 "loses"
               end

        if goal['Type'] == 'Goal'
          message = I18n.t("opta.f7.goal.#{type}",
                           :shirt_number => shirt_number(player_ref, team),
                           :name => player_name(player_ref, team_ref),
                           :minute => goal['Time'],
                           :team => team_name(team_ref),
                           :team_score => team_score,
                           :opponent_score => opponent_score
                          )
          post = create_post message, 'Goals', [player_tag, team_tag, build_match_tag]
          Reshare.goal(
            post,
            :player => player_tag.owner,
            :team => team_tag.owner
          )

          if goal["Assist"]
            assist_ref = goal["Assist"][0]['PlayerRef']
            message = I18n.t("opta.f7.assist",
                             :shirt_number => shirt_number(assist_ref, team),
                             :name => player_name(assist_ref, team_ref),
                             :minute => goal['Time'],
                             :team => team_name(team_ref),
                             :scored_player => player_last_name(player_ref, team_ref)
                            )

                            assist_tag = build_player_tag(assist_ref)
                            post = create_post message, 'Assists', [assist_tag, team_tag, build_match_tag]

                            Reshare.assist(
                              post,
                              :player=> assist_tag.owner
                            )
          end
        elsif goal['Type'] == 'Own'
          message = I18n.t("opta.f7.own_goal",
                           :shirt_number => shirt_number(player_ref, team_by_index(team_ind)),
                           :name => player_name(player_ref, team_ref_by_index(team_ind)),
                           :minute => goal['Time'],
                           :team => team_name(team_ref)
                          )
                          post = create_post message, 'OwnGoals', [player_tag, team_tag, build_match_tag]
                          Reshare.own_goal(
                            post,
                            :player => player_tag.owner,
                            :team_ref => team_tag.owner
                          )
        elsif goal['Type'] == 'Penalty'
          if period == 'ShootOut'

            team_before_score = 0
            opponent_before_score = 0

            first_shootout = RawStat.order('created_at asc').where(:game_id => game_id, :period => 'ShootOut').first rescue nil
            if first_shootout

              before_shootout = RawStat.order('created_at desc').where("game_id = #{game_id} and id < #{first_shootout.id}").first rescue nil
              if before_shootout
                hash = XmlSimple.xml_in(before_shootout.raw_post)
                handler = Opta::Handlers::F7Goal.new(game_id, hash, nil)
                before_teams_with_goals = handler.teams_with_goals
                team_before_score = before_teams_with_goals[ind][:goals]
                opponent_before_score = before_teams_with_goals[1-ind][:goals]
              end
            end

            team_shootout_score = team_score - team_before_score
            opponent_shootout_score = opponent_score - opponent_before_score

            first = ""
            if team['ShootOut']
              first_penalty = team['ShootOut'][0]['FirstPenalty']
              first_penalty = first_penalty[0] || first_penalty
              if first_penalty.to_i == 1
                first = "first"
              end
            end

            message = I18n.t("opta.f7.shootout_kick",
                             :shirt_number => shirt_number(player_ref, team),
                             :name => player_name(player_ref, team_ref),
                             :minute => goal['Time'],
                             :team => team_name(team_ref),
                             :first => first,
                             :team_before_score => team_before_score,
                             :opponent_before_score => opponent_before_score,
                             :team_shootout_score => team_shootout_score,
                             :opponent_shootout_score => opponent_shootout_score
                            )
                            post = create_post message, 'Penalties', [player_tag, team_tag, build_match_tag]
                            Reshare.penalty_goal(
                              post,
                              :player => player_tag.owner,
                              :team_ref => team_tag.owner
                            )
          else
            message = I18n.t("opta.f7.penalty.#{type}",
                             :shirt_number => shirt_number(player_ref, team),
                             :name => player_name(player_ref, team_ref),
                             :minute => goal['Time'],
                             :team => team_name(team_ref),
                             :team_score => team_score,
                             :opponent_score => opponent_score
                            )
                            post = create_post message, 'Penalties', [player_tag, team_tag, build_match_tag]
                            Reshare.penalty(
                              post,
                              :player => player_tag.owner
                            )
          end
        end

        update_event_teams_scores teams
      end

    end
  end
end
