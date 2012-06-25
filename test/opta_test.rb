require 'test_helper'

class OptaControllerTest < ActionController::IntegrationTest
  context "Receiving a push from Opta" do
    setup  do
      Resque.reset!
      post "/opta/push", {:stuff => "test"}, {"HTTP_X_META_FEED_TYPE" => "foo"}
      @stat = RawStat.last
    end
    

    should "create a RawStat object" do
      assert_equal(1, RawStat.count)
      assert_equal({"stuff"=>"test", "controller"=>"v2/opta", "action"=>"push"}, @stat.params)
      assert_equal({"HTTP_X_META_FEED_TYPE" => "foo"}, @stat.headers)
    end

    should "enqueue the RawStat in Resque for processing" do
      assert_queued(Opta::Worker, [{
        :id => @stat.id,
        :feed_type => "foo"
      }])
    end
  end
end
 
