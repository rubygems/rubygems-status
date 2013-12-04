class StatusController < ApplicationController
  before_filter :load_services

  def show
    respond_to do |f|
      f.html { render }
      f.json { render :json => json_status }
    end
  end

  private

  def load_services
    @pings   = Ping.all.sort_by { |x| x.service }
    critical = @pings.any? { |x| x.down? and x.critical? }

    if @pings.empty?
      @status = "unknown"
    elsif critical
      @status = "down"
    else
      @status = @pings.any? { |x| x.down? } ? "partial" : "up"
    end
  end

  def json_status
    {:status => @status, :services => @pings}
  end
end
