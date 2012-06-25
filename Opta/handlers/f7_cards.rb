module Opta
  module Handlers
    class F7Cards < Opta::BaseHandler
      include Opta::Handlers::Common::F7Common

      def process
        return unless need_to_process

        if self.prev_hash

          new_bookings = teamdata_diff_elements 'Booking'

          #TODO: Find teams and cache here
          new_bookings.each do |b|
            if b[:element]['Card'] == 'Yellow'
              post_yellow b[:element], b[:team]
            elsif b[:element]['Card'] == 'Red'
              post_red b[:element], b[:team]
            end
          end

        end
      end


      def get_message translation, booking, team
        reason = booking['Reason'] || "unknown"
        I18n.t(translation,
                :team => team_name(team['TeamRef']),
                :shirt_number => shirt_number(booking['PlayerRef'], team),
                :name => player_name(booking['PlayerRef'], team['TeamRef']),
                :reason => reason.downcase,
                :minute => booking['Time']
        )
      end

      def post_yellow booking, team
        
        team_tag = build_team_tag(team['TeamRef'])
        return if team_tag.nil?

        player_tag = build_player_tag(booking['PlayerRef'])

        message = get_message("opta.f7.yellow_card", booking, team)
        post = create_post message, 'Yellow Cards', [player, team_tag, build_match_tag]

        Reshare.yellow_card(
          post,
          :player => player_tag.owner
        )
      end

      def post_red booking, team
        
        team_tag = build_team_tag(team['TeamRef'])
        return if team_tag.nil?
        player_tag = build_player_tag(booking['PlayerRef'])


        message = get_message("opta.f7.red_card", booking, team)
        post = create_post message, 'Red Cards', [player, team_tag, build_match_tag]

        Reshare.red_card(
          post,
          :player =>player_tag.owner,
          :team => team_tag.owner
        )
      end

    end
  end
end
