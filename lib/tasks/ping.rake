require File.expand_path('../../../app/workers/ping', __FILE__)

namespace :ping do
  desc "checks RubyGems.org status once"
  task :once => :environment do
    pw = PingWorker.new
    pw.update
  end

  desc "checks RubyGems.org status every 60 seconds"
  task :forever => :environment do
    pw = PingWorker.new
    while true
      pw.update
      sleep 60
    end
  end
end


