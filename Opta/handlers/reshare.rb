module Opta
  module Handlers
    module Reshare
      class << self
        attr_accessor :subs, :goals
      end

      def self.starter_teams(post, args = {})
        #share_to_team(post, :team_name => args[:team_name1])
        #share_to_team(post, :team_name => args[:team_name2])
      end

      def self.injury(post, args = {})
        @subs ||= User.where(first_name: "Subs").first
        res = @subs.reshare_post!(post)

        share_to_player(post, :player => args[:player_in])
        share_to_player(post, :player=> args[:player_out])
        share_to_team(post, args)
      end

      def self.share_to_player(post, args = {})
        player = args[:player]
        if player.nil?
          Rails.logger.warn("** OPTA Reshare to Player: player is nil")
          return
        end
        player.reshare_post!(post)
      end

      def self.share_to_team(post, args = {})
        team = args[:team]
        if team.nil? || team.user.nil?
          Rails.logger.warn("** Reshare to team: Team is nil")
          return
        end
        team.user.reshare_post!(post)
      end

      def self.share_to_both_teams(post, args = {})
        Rails.logger.debug "OPTA Reshare to Both teams: #{args.inspect}"
        [
          args[:team1],
          args[:team2]
        ].each do |o|
          o.user.reshare_post!(post)
        end
      end

      def self.share_to_player_and_team(post, args = {})
        share_to_player(post, args)
        share_to_team(post, args)
      end

      def self.share_to_goals_and_player_and_team(post, args = {})
        share_to_player_and_team(post, args)

        @goals ||= User.where(first_name: "Goals").first
        @goals.reshare_post!(post)
      end

      def self.noop *args
       # Nooping stuff for now
      end

      class << self
        alias_method :yellow_card,      :noop
        alias_method :red_card,         :noop
        alias_method :final_score,      :share_to_both_teams
        alias_method :goal,             :share_to_player_and_team
        alias_method :assist,           :share_to_player
        alias_method :own_goal,         :share_to_goals_and_player_and_team
        alias_method :penalty_goal,     :share_to_goals_and_player_and_team
        alias_method :penalty,          :noop
        alias_method :halftime_score,   :share_to_both_teams
        alias_method :overtime,         :noop
        alias_method :postponed,        :noop
        alias_method :shootout_begins,  :noop
      end
    end
  end
end
