require 'test_helper'
require 'xmlsimple'

class F40PlayerUpdateHandlerTest < ActiveSupport::TestCase

  context "Failed Player Update Error from Heroku" do
    setup do
      hash = XmlSimple.xml_in("#{Rails.root}/test/fixtures/failed_f40_player_update.xml")
      stub(Team).find_or_create_by_opta_id_and_name! {Factory(:team)}
      @handler = Opta::Handlers::F40PlayerUpdate.new(1, hash, nil)
    end

    should "not error" do
      @handler.process
    end
 
  end
  context "Another failed player update" do
  
    setup do
      hash = XmlSimple.xml_in("#{Rails.root}/test/fixtures/failed_f40_player_update2.xml")
      @handler = Opta::Handlers::F40PlayerUpdate.new(1, hash, nil)
    end

    should "not fail" do
      @handler.process
    end
  
  end

end
