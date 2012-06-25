require 'test_helper'
require 'xmlsimple'

class F1TeamUpdateTest < ActiveSupport::TestCase

  context "Processing a document" do
    setup do
      @hash = XmlSimple.xml_in(File.read("#{Rails.root}/test/fixtures/opta_f1_mls.xml"))
      @f1eventupdate = Opta::Handlers::F1TeamUpdate.new(nil, @hash, nil)
      @f1eventupdate.process
    end

    should "create a user for team if it doesn't have one" do
      assert_equal(19, Team.count)
    end

    should "assign each Team to the same league" do
      league_id = Team.first.league_id
      assert Team.all.all? { |t| t.league_id == league_id }
    end
  end
end
