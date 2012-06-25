require 'test_helper'
require 'xmlsimple'

class F7HandlerTest < ActiveSupport::TestCase

  context "F7EventHandler" do

    setup do
      hash = XmlSimple.xml_in("#{Rails.root}/test/fixtures/opta_f7_update.xml")
      stub(Event).find_or_create_by_opta_id_and_team1_and_team2_and_starting_at!
      @handler = Opta::Handlers::F7EventUpdate.new(1, hash, nil)
      @handler.process
    end

    should "create a Location based on Venue data" do
      location = Location.first
      assert_not_nil(location)
    end

    should "be able to get venue unique name" do
      assert_equal("Old Trafford", @handler.get_venue_name)
    end

    should "be able to get venue unique id" do
      assert_equal("v28", @handler.get_venue_id)
    end

    should "be able to get venue unique id" do
      assert_equal("England", @handler.get_venue_country)
    end
  end

  context "F7GoalHandler" do
    setup do
      [1841, 40204, 5741].each {|o| Factory(:player, opta_id: o)}

      @user = Factory(:user, :kind => :system, :first_name=>'Goals')
      @assists = Factory(:user, :kind => :system, :first_name=>'Assists')
      @player_user = Factory(:user)
      @team = Factory(:team, :kind => "system", :opta_id => 45 )
      @team.primary_name = @team.name
      @team.save
      @player = Factory(:player, :opta_id => '40451', :user=> @player_user, :team => @team )
      
      @player.team.reload
      @hash1 = XmlSimple.xml_in("#{Rails.root}/test/fixtures/opta_f7_update_1.xml")
      handler = Opta::Handlers::F7EventUpdate.new('u8', @hash1, nil)
      handler.process

      @hash2 = XmlSimple.xml_in("#{Rails.root}/test/fixtures/opta_f7_update_2.xml")
      @message = "#5 Steve Morison scored at 77' & Norwich City loses 2-3."
      @handler = Opta::Handlers::F7Goal.new('u8', @hash2, @hash1)
      stub(@handler).need_to_process.returns(true)
      @handler.process
    end


    should "send out goal kycks from Goal user" do
      post = @user.posts.last
      assert_equal(@message, post.text)
    end

    should "tag goal kycks with player" do
      tagged = false
      tag = Tag.where("owner_type = 'User' and owner_id=?", @player.user.id).first
      @user.posts.each do |p|
        tagged = true if p.tags.where(:owner_id => @player.user.id).first.present?
      end

      assert tagged
    end

  end

  context "F7GoalHandler Own Goals" do
    setup do
      [1841, 40204, 5741].each {|o| Factory(:player, opta_id: o)}
      Factory(:user, :first_name => "OwnGoals", :kind => :system)
      Factory(:user, :first_name => "Goals", :kind => :system)

      Factory(:team, :kind => "system", :opta_id => 56)
      hash1 = XmlSimple.xml_in("#{Rails.root}/test/fixtures/opta_f7_update.xml")
      hash2 = XmlSimple.xml_in("#{Rails.root}/test/fixtures/opta_f7_update.xml")
      hash1["SoccerDocument"].first["MatchData"].first["TeamData"].each do |hash|
        hash.delete "Goal"
      end
      @handler = Opta::Handlers::F7Goal.new(1, hash2, hash1)
      stub(@handler).need_to_process.returns(true)
      @handler.process
    end

    should "create an Own Goal Kyck by Wes Brown of Sunderland" do
      assert(
        Post.where("text like ?", "%Wes Brown%").first,
        "Should have a Kyck of an Own Goal by Sunderland's Wes Brown from opta_f7_update.xml"
      )
    end
  end

  context "getting the venue country" do
    setup do
      @handler = Object.new
      class << @handler
        include Opta::Handlers::Common::F7Common
      end
      def @handler.document
        {"Venue" => [{"uID" => "333"}]}
      end
    end
    should "return empty string if the venue does not include country" do
      assert_equal "", @handler.get_venue_country
    end
  end

  context "Another opta failure" do
    should "not fail" do
      @hash1 = XmlSimple.xml_in("#{Rails.root}/test/fixtures/opta/opta_f7_update_4.xml")
      handler = Opta::Handlers::F7EventUpdate.new('u8', @hash1, nil)
      handler.process
    end

  end
end
