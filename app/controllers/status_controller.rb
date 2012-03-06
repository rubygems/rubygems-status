class StatusController < ApplicationController
  def show
    @core = Ping.find_by_service("Core API")
    @pings = Ping.all.sort_by { |x| x.service }

    if !@core
      @status = "unknown"
    elsif @core.status == "down"
      @status = "down"
    else
      @status = @pings.any? { |x| x.down? } ? "partial" : "up"
    end
  end

  def system
  end

end
