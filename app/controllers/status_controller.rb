class StatusController < ApplicationController
  def show
    @core = Ping.find_by_service("Core API")
    if !@core
      @status = "unknown"
    else
      @status = @core.status
    end

    @status = "up"
    @pings = Ping.all.sort_by { |x| x.service }
  end

  def system
  end

end
