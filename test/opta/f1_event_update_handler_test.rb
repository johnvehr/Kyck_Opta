require 'test_helper'
require 'xmlsimple'

class F1EventUpdateHandlerTest < ActiveSupport::TestCase

  context "Processing a document" do
    setup do
      @hash = XmlSimple.xml_in(File.read("#{Rails.root}/test/fixtures/opta/usa_v_brazil.xml"))
      @f1eventupdate = Opta::Handlers::F1EventUpdate.new(nil, @hash, nil)
      @f1eventupdate.process
    end

    should "create a Event" do
      assert Event.where(opta_id: 432238).first.present?
    end

    should "create the right date" do
      ev = Event.last
      assert_equal DateTime.parse("2012-05-31 01:00:00 BST").utc, ev.starting_at
    end
  end
end
