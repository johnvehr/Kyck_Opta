require 'test_helper'

class ReshareTest < ActiveSupport::TestCase

  setup do
    @kyck = Factory(:kyck)
    [Factory(:event_tag), Factory(:location_tag)].each do |tag|
      @kyck.tags << tag
    end
  end

  context "#starter_teams" do
    setup do
      @team1, @team2 = (1..2).map { Factory(:team) }
      Opta::Handlers::Reshare.starter_teams(@kyck, :team1 => @team1, :team2 => @team2)
      @reshare1 = @kyck.reshares.first
      @reshare2 = @kyck.reshares.last
    end

    should "not create any new Posts" do
      assert_equal(1, Post.count)
    end
  end

  context "#injury" do
    setup do
      @team = Factory(:team, :kind => "system")
      @team.primary_name = @team.name
      @team.save
      @player_in, @player_out = (1..2).map { Factory(:player, :team => @team) }

      # MUST DI a Subs user because he changes each iteration
      @subs = Factory(:user, :last_name => "Subs")
      Opta::Handlers::Reshare.subs = @subs
      Opta::Handlers::Reshare.injury(@kyck,
        :player_in => @player_in.user,
        :player_out => @player_out.user,
        :team => @team
      )

      @in_reshare = @kyck.reshares.where("user_id = #{@player_in.user.id}").last
      @out_reshare = @kyck.reshares.where("user_id = #{@player_out.user.id}").last
      @team_reshare = @kyck.reshares.where("user_id = #{@team.user.id}").last
      @subs_reshare = @kyck.reshares.where("user_id = #{@subs.id}").last
    end

    should "be reshared by the specified IN player" do
      assert_equal @player_in.user_id, @in_reshare.user_id
    end

    should "be reshared by the specified OUT player" do
      assert_equal @player_out.user_id, @out_reshare.user_id
    end

    should "be reshared by specified Team" do
      assert_equal @team.user_id, @team_reshare.user_id
    end

    should "be reshared by the 'Subs' user" do
      assert_equal @subs.id, @subs_reshare.user_id
    end

  end

  context "#share_to_player" do
    setup do
      @player = Factory(:player)
      Opta::Handlers::Reshare.share_to_player(@kyck,
        :player => @player.user,
      )
    end

    should "be reshared by specified player" do
      assert_not_nil @kyck.reshares.where(user_id: @player.user_id).first
    end
  end

  context "#share_to_team" do
    setup do
      @team = Factory(:team)
      Opta::Handlers::Reshare.share_to_team(@kyck,
        :team => @team
      )
    end

    should "be reshared by the specified Team" do
      assert_not_nil @kyck.reshares.where(user_id: @team.user_id).first
    end

  end

  context "#share_to_both_teams" do
    setup do
      @team1, @team2 = (1..2).map { Factory(:team) }
      Opta::Handlers::Reshare.share_to_both_teams(@kyck,
        :team1 => @team1,
        :team2 => @team2
      )
    end

    should "be reshared by the specified Team 1" do
      assert_not_nil @kyck.reshares.where(user_id: @team1.user_id).first
    end

    should "be reshared by the specified Team 2" do
      assert_not_nil @kyck.reshares.where(user_id: @team2.user_id).first
    end

  end

  context "#share_to_player_and_team" do
    setup do
      @player = Factory(:player)
      @team = Factory(:team)
      Opta::Handlers::Reshare.share_to_player_and_team(@kyck,
        :team => @team,
        :player => @player.user
      )
    end

    should "be reshared bythe specified Team" do
      assert_not_nil @kyck.reshares.where(user_id: @team.user_id).first
    end

    should "create a duplicate post from the specified player" do
      assert_not_nil @kyck.reshares.where(user_id: @player.user_id).first
    end

  end

  context "#share_to_goals_and_player_and_team" do
    setup do
      @goals = Factory(:user, :last_name => "Goals")
      @player = Factory(:player)
      @team = Factory(:team)
      Opta::Handlers::Reshare.goals = @goals
      Opta::Handlers::Reshare.share_to_goals_and_player_and_team(@kyck,
        :team=> @team,
        :player=> @player.user
      )
    end

    should "be reshared by the specified Team" do
      assert_not_nil @kyck.reshares.where(user_id: @team.user_id).first
    end

    should "be reshared by the specified player" do
      assert_not_nil @kyck.reshares.where(user_id: @player.user_id).first
    end

    should "be reshared by the Goals user" do
      assert_not_nil @kyck.reshares.where(user_id: @goals.id).first
    end

  end
end
