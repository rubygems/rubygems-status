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

  def update_status(flag, service)
    x = Ping.find_by_service service
    x = Ping.new :service => service unless x

    x.status = (flag ? "up" : "down")
    x.save
    x.touch
  end

  def update
    s = TCPSocket.new "rubygems.org", 80
    s << "GET /latest_specs.4.8.gz HTTP/1.0\r\nHost: rubygems.org\r\n\r\n"

    s2 = TCPSocket.new "rubygems.org", 80
    s2 << "GET / HTTP/1.0\r\nHost: rubygems.org\r\n\r\n"

    @core_api = false
    @app = false
    @push_api = false

    sockets = [s, s2]

    until sockets.empty?
      r, _, _ = IO.select(sockets, nil, nil, @timeout)
      r.each do |x|
        case x
        when s
          @core_api = check_socket(s)
        when s2
          @app = check_socket(s2)
          @push_api = @app
        end
      end

      sockets -= r
    end

    update_status @core_api, "Core API"
    update_status @app, "Application"
    update_status @push_api, "Push API"
  end
end
