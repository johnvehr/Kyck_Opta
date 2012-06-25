require 'test_helper'
require 'xmlsimple'

class F7GoalTest < ActiveSupport::TestCase

  context "Processing a document" do
    setup do
      @event = Factory(:event, opta_id: 432238)
      @player = Factory(:player, opta_id: 41602)
      @other_scorer = Factory(:player, opta_id: 39563)
      @other_assister = Factory(:player, opta_id: 61278)
      [45215].each {|opta_id| Factory(:player, opta_id: opta_id)}
      @assister = Factory(:player, opta_id: 37070)
      @goals = Factory(:user, kind: :system, first_name: "Goals")
      @assists = Factory(:user, kind: :system, first_name: "Assists")
      @usa = Factory(:team, opta_id: 596)
      @brazil = Factory(:team, opta_id: 614)
      @hash = XmlSimple.xml_in(File.read("#{Rails.root}/test/fixtures/opta/usa_v_brazil_goals2.xml"))
      @prev_hash = XmlSimple.xml_in(File.read("#{Rails.root}/test/fixtures/opta/usa_v_brazil_goals1.xml"))
      @f7goal = Opta::Handlers::F7Goal.new(nil, @hash, @prev_hash)
      @f7goal.process
    end

    should "create a Event" do
      assert Event.where(opta_id: 432238).first.present?
    end

    should "create a reshare for player ref 41602" do
      assert_not_nil Post::Reshare.where(user_id: @player.user_id).first
    end

    should "create a reshare for the assiter" do
      assert_not_nil Post::Reshare.where(user_id: @assister.user_id).first
    end

    should "create a reshare for the team" do
      assert_not_nil Post::Reshare.where(user_id: @usa.user_id).first
    end
    
    context "for the goals kyck" do
      should "have a reshares count" do
        # Rails testing doubles this for some reason
        assert @goals.posts.last.reshares_count > 0
      end
    end

  end
end
