require 'test_helper'
require 'xmlsimple'

class F7FinalScoreTest < ActiveSupport::TestCase

  context "Processing a document" do
    setup do
      @event = Factory(:event, opta_id: 432238)
      @player = Factory(:player, opta_id: 41602)
      @assister = Factory(:player, opta_id: 37070)
      @goals = Factory(:user, kind: :system, first_name: "Goals")
      @assists = Factory(:user, kind: :system, first_name: "Assists")
      @scores = Factory(:user, kind: :system, first_name: "Scores")
      @usa = Factory(:team, opta_id: 596)
      @brazil = Factory(:team, opta_id: 614)
      @hash = XmlSimple.xml_in(File.read("#{Rails.root}/test/fixtures/opta/usa_v_brazil_fulltime.xml"))
      @prev_hash = XmlSimple.xml_in(File.read("#{Rails.root}/test/fixtures/opta/usa_v_brazil_goals1.xml"))
      @f7final_score = Opta::Handlers::F7FinalScore.new(432238, @hash, @prev_hash)
      @f7final_score.process
    end

    should "mark event final" do
      assert Event.where(opta_id: 432238).first.final?
    end

    should "create a reshare for team1" do
      assert_not_nil Post::Reshare.where(user_id: @usa.user_id).first
    end
    
    should "create a reshare for team2" do
      assert_not_nil Post::Reshare.where(user_id: @brazil.user_id).first
    end
  end
end
