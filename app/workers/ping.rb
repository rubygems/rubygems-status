require 'socket'

class PingWorker
  def initialize
    @timeout = 10
  end

  def check_socket(s)
    data = s.gets
    data =~ %r!^HTTP/1\.\d (\d)(\d{2})!
    $1.to_i != 5 if $1
  end

  def update_raw_status(status, service)
    x = Ping.find_by_service service

    x = Ping.new :service => service unless x

    x.status = status
    x.last_seen = Time.now
    x.save
  end

  def update_status(flag, service)
    update_raw_status(flag ? "up" : "down", service)
  end

  def update
    s = TCPSocket.new "rubygems.org", 80
    s << "HEAD /latest_specs.4.8.gz HTTP/1.0\r\nHost: rubygems.org\r\n\r\n"

    s2 = TCPSocket.new "rubygems.org", 80
    s2 << "HEAD / HTTP/1.0\r\nHost: rubygems.org\r\n\r\n"

    s3 = TCPSocket.new "rubygems.org", 80
    s3 << "HEAD /api/v1/downloads HTTP/1.0\r\nHost: rubygems.org\r\n\r\n"

    s4 = TCPSocket.new "f1.rubygems.org", 80
    s4 << "HEAD /latest_specs.4.8.gz HTTP/1.0\r\nHost: rubygems.org\r\n\r\n"

    s5 = TCPSocket.new "f2.rubygems.org", 80
    s5 << "HEAD /latest_specs.4.8.gz HTTP/1.0\r\nHost: rubygems.org\r\n\r\n"

    @core_api = false
    @app = false
    @v1_api = false
    @push_api = false
    @lb = 0
    @f1 = false
    @f2 = false

    sockets = [s, s2, s3, s4, s5]

    until sockets.empty?
      r, _, _ = IO.select(sockets, nil, nil, @timeout)
      r.each do |x|
        case x
        when s
          @core_api = check_socket(s)
        when s2
          @app = check_socket(s2)
        when s3
          @v1_api = check_socket(s3)
          @push_api = @v1_api
        when s4
          @f1 = check_socket(s4)
          @lb += 1 if @f1
        when s5
          @f2 = check_socket(s5)
          @lb += 1 if @f2
        end
      end

      sockets -= r
    end

    update_status @core_api, "Core API"
    update_status @app, "Application"
    update_status @push_api, "Push API"
    update_status @v1_api, "V1 API"

    status = case @lb
             when 0
               "down"
             when 1
               "partial"
             else
               "up"
             end

    update_raw_status status, "Load Balancers"
  end
end
