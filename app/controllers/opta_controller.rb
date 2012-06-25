class OptaController < ApplicationController

  skip_before_filter :authenticate_user!

  def push
    feed_type = request.env['HTTP_X_META_FEED_TYPE']

    render :text => 'Error: no meta data' and return unless feed_type

    raw_stat_params = {
        :game_id => request.env['HTTP_X_META_GAME_ID'],
        :feed_type => request.env['HTTP_X_META_FEED_TYPE'],
        :file_name => request.env['HTTP_X_META_DEFAULT_FILENAME'],
        :headers => (request.env.select { |k, _| k.match("^HTTP_X_META_.*") }),
        :params => params,
        :raw_post => request.raw_post
    }
    stat = RawStat.create! raw_stat_params

    Resque.enqueue(Opta::Worker, :id => stat.id, :feed_type => feed_type)

    render :text => 'Ok'
  end

  def push_test
    sample = RawStat.find params[:id]

    emulate_push sample
  end

  def push_test_many
    #raw_stats = RawStat.where(:feed_type => 'F1').order("created_at desc").take(2).to_a
    #raw_stats = RawStat.where("feed_type='F7' and (period ='PreMatch' or period='FirstHalf')").order("id asc")
    #raw_stats = RawStat.where(:feed_type => 'F7', :game_id=>370478).order("id asc")
    raw_stats = RawStat.order("id desc").take(10)
    raw_stats.reverse!

    #raw_stats = RawStat.where(:id => 11879)

    raw_stats.each do |sample|

      p "processing id=#{sample.id}..."

      #prepare
      self.params = sample.params
      self.request.env['RAW_POST_DATA'] = sample.raw_post
      sample.headers.each do |key, value|
        request.env[key] = value
      end

      #emulating
      raw_stat_params = {
          :game_id => request.env['HTTP_X_META_GAME_ID'],
          :feed_type => request.env['HTTP_X_META_FEED_TYPE'],
          :file_name => request.env['HTTP_X_META_DEFAULT_FILENAME'],
          :headers => (request.env.select { |k, _| k.match("^HTTP_X_META_.*") }),
          :params => params,
          :raw_post => request.raw_post
      }

      if request.env['HTTP_X_META_FEED_TYPE']
        stat = RawStat.create! raw_stat_params

        manager = Opta::FeedManager.new raw_stat_params[:feed_type]
        begin
          manager.process stat
        rescue => e
          p e
        end
        manager = nil
      end

      p "done, waiting for next.."
      sleep 1.seconds

    end
    render :text => "Ok"
  end


  def show_raw_stat
    #@raw_stats = RawStat.where(:game_id=>370478, :period => 'PreMatch').order("id asc")
    @raw_stats = RawStat.where(:feed_type => 'F1').order("id desc").take(10)
    @raw_stats.reverse!
    render 'home/show_raw_stat'
  end

  protected

  def emulate_push sample
    self.params = sample.params
    self.request.env['RAW_POST_DATA'] = sample.raw_post
    sample.headers.each do |key, value|
      request.env[key] = value
    end

    push
  end

end

