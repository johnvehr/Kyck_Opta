module Opta
  module Handlers
    module Common
      module F7Common
        extend ActiveSupport::Concern
        include Opta::Handlers::Common::FeedCommon

        def need_to_process
          match_date = DateTime.parse(document['MatchData'][0]['MatchInfo'][0]['Date'][0])
          feed_date = DateTime.parse(self.hash['TimeStamp'])
          feed_date - 24.hours < match_date
        end

        def prev_document
          self.prev_hash['SoccerDocument'][0]
        end

        def get_venue_name
          document['Venue'][0]['Name'][0]
        end

        def get_venue_id
          document['Venue'][0]['uID']
        end

        def get_venue_country
          begin
            document['Venue'][0]['Country'][0]
          rescue
            ""
          end
        end

        def get_player_info player_ref, team_ref
          document['Team'].find { |t| t['uID'] == team_ref }['Player'].find { |p| p['uID'] == player_ref }
        end

        def team_name ref
          document['Team'].find { |t| t['uID'] == ref }['Name'][0]
        end

        def team_name_by_index index
          team_name team_ref_by_index(index)
        end

        def team_ref_by_index index
          document['MatchData'][0]['TeamData'][index]['TeamRef']
        end

        def team_by_index index
          document['MatchData'][0]['TeamData'][index]
        end

        def teams_with_goals
          hash_teams = document['MatchData'][0]['TeamData']
          teams = []
          hash_teams.each_with_index do |team, i|
            teams[i] = {
                :goals => team['Score'],
                :name => team_name(team['TeamRef']),
                :ref => team['TeamRef']
            }
            if team['Goal']
              team['Goal'] = [team['Goal']] if team['Goal'].is_a? Hash
              teams[i][:goals] = team['Goal'].size
            end
            teams[i][:goals] = teams[i][:goals].to_i
          end
          teams
        end

        def player_name player_ref, team_ref
          player_info = get_player_info player_ref, team_ref
          if player_info['PersonName'][0]['Known']
            full_name = player_info['PersonName'][0]['Known'][0]
          else
            full_name = "#{player_info['PersonName'][0]['First'][0]} #{player_info['PersonName'][0]['Last'][0]}"
          end
          full_name
        end

        def player_first_name player_ref, team_ref
          player_info = get_player_info player_ref, team_ref
          player_info['PersonName'][0]['First'][0]
        end

        def player_last_name player_ref, team_ref
          player_info = get_player_info player_ref, team_ref
          player_info['PersonName'][0]['Last'][0]
        end

        def teamdata_diff_elements element
          teamdata = document['MatchData'][0]['TeamData']
          prev_teamdata = prev_document['MatchData'][0]['TeamData']

          new_els = []

          teamdata.each_with_index do |data, i|
            els = data[element]
            prev_els = prev_teamdata[i][element]

            els = [els] if els.is_a? Hash
            prev_els = [prev_els] if prev_els.is_a? Hash

            if els && (prev_els.blank? || els.size > prev_els.size)
              prev_hashes = prev_els.collect { |e| e['EventID'] } rescue []
              els.each do |g|
                unless prev_hashes.include?(g['EventID'])
                  new_els << { :element => g, :team => data, :team_index => i }
                end
              end
            end
          end

          new_els
        end

        def shirt_number player_ref, team
          team['PlayerLineUp'][0]['MatchPlayer'].find{ |p| p['PlayerRef'] == player_ref }['ShirtNumber']
        end

        def build_player_tag player_ref
          player = Player.where(:opta_id => player_ref.sub("p", "").to_i).first rescue nil
          puts player_ref if player.nil?
          player ? player.main_tag  : nil
        end

        def build_team_tag team_ref
          team = Team.where(:opta_id => team_ref.sub("t", "").to_i, :kind => "system").first rescue nil
          team ? team.primary_tag : nil
        end

        def build_match_tag
          event = Event.where(:opta_id => game_id.to_i).first rescue nil
          event ? event.main_tag : nil
        end

        def update_event_teams_scores teams, final = false
          event = Event.where(:opta_id => game_id.to_i).first rescue nil
          if event
            event.team1_score = teams[0][:goals]
            event.team2_score = teams[1][:goals]
            event.final = final
            event.save!
          end
        end

        def period_become new_period
          prev_period = self.prev_hash ? prev_document['MatchData'][0]['MatchInfo'][0]['Period'] : nil
          period == new_period && prev_period != period
        end

        def game_result_become new_result
          if document['MatchData'][0]['MatchInfo'][0]['Result']
            result = document['MatchData'][0]['MatchInfo'][0]['Result'][0]['Type']
            if self.prev_hash && prev_document['MatchData'][0]['MatchInfo'][0]['Result']
              prev_result = prev_document['MatchData'][0]['MatchInfo'][0]['Result'][0]['Type']
            else
              prev_result = nil
            end
            return result == new_result && prev_result != result
          end
          false
        end

        def period
          document['MatchData'][0]['MatchInfo'][0]['Period']
        end

      end
    end
  end
end
