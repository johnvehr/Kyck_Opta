ENV["REDISTOGO_URL"] ||= "redis://localhost:6379/"

uri = URI.parse(ENV["REDISTOGO_URL"])

#FIXME: This is a monkey patch to apn_sender's monkey patch....sigh
module Resque
  class Worker
     def run_hook(name, *args)
      hook = APN::QueueManager.send(name) || Resque.send(name)
      return unless hook
      msg = "Running #{name} hook"
      msg << " with #{args.inspect}" if args.any?
      log msg

      args.any? ? hook.call(*args) : hook.call
    end
  end
end

args = {
  :host => uri.host,
  :port => uri.port,
  :password => uri.password
}

if Rails.env == "test"
  args[:db] = 1
end

Resque.redis = Redis.new(args)

# This rids of of connection reset errors on heroku postgres
APN::NotificationJob.extend Resque::Heroku


