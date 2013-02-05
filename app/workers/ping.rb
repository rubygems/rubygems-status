require 'socket'

class PingWorker
  def initialize
    @timeout = 10
  end

  def check_socket(s)
    data = s.gets
    data =~ %r!^HTTP/1\.\d (\d)(\d{2})!
    ![4, 5].include?($1.to_i) if $1
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
    s2 << "HEAD /stats HTTP/1.0\r\nHost: rubygems.org\r\n\r\n"

    s3 = TCPSocket.new "rubygems.org", 80
    s3 << "HEAD /api/v1/downloads HTTP/1.0\r\nHost: rubygems.org\r\n\r\n"

    s4 = TCPSocket.new "lb01-aws.rubygems.org", 80
    s4 << "HEAD /latest_specs.4.8.gz HTTP/1.0\r\nHost: rubygems.org\r\n\r\n"

    s6 = TCPSocket.new "rubygems.org", 80
    s6 << "HEAD /api/v1/dependencies HTTP/1.0\r\nHost: rubygems.org\r\n\r\n"

    @core_api = false
    @app = false
    @v1_api = false
    @push_api = false
    @lb = 0
    @lb01 = false
    @dep_api = false

    sockets = [s, s2, s3, s4, s6]

    fin = Time.now + @timeout

    until sockets.empty?
      r, _, _ = IO.select(sockets, nil, nil, @timeout)

      break if Time.now > fin

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
          @lb01 = check_socket(s4)
          @lb += 1 if @lb01
        when s6
          @dep_api = check_socket(s6)
        end
      end

      sockets -= r
    end

    update_status @core_api, "Core API"
    update_status @app, "Application"
    update_status @push_api, "Push API"
    update_status @v1_api, "V1 API"
    update_status @dep_api, "Dependency API"

    status = (@lb > 0 ? "up" : "down")

    update_raw_status status, "Load Balancers"
  end
end
