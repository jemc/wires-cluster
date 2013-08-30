
require 'socket'
require 'ipaddr'

module UDP
  class << self;  attr_accessor :max_length;  end
  self.max_length = 65507
  
  class RX
    def initialize(group, port)
      @group = group
      @port  = port
      bind
    end
    
    def bind
      @socket.close if @socket
      @socket = UDPSocket.new
      @socket.setsockopt Socket::IPPROTO_IP,
                         Socket::IP_ADD_MEMBERSHIP,
                         IPAddr.new(@group).hton + IPAddr.new("0.0.0.0").hton
      # @socket.setsockopt Socket::SO_REUSEADDR, [1].pack('i')
      
      @socket.bind Socket::INADDR_ANY, @port
      return @socket
    ensure
      ObjectSpace.define_finalizer self, Proc.new { @socket.close }
    end
    
    def gets
      msg, addrinfo = @socket.recvfrom(UDP.max_length)
      msg.instance_variable_set :@source, addrinfo[3].to_s+':'+addrinfo[1].to_s
      class << msg;  attr_reader :source;  end
      msg
    end
    
    def test!
      tx = UDP::TX.new @group, @port
      rx = self
      
      outer_thread = Thread.current
      passed = false
      thr = Thread.new do
        rx.gets
        passed = true
        outer_thread.wakeup
      end
      Thread.pass
      
      tx.puts 'test-string'
      sleep 1
      thr.kill
      
      passed
    end
  end
  
  class TX
    def initialize(group, port)
      @group = group
      @port  = port
      bind
    end
    
    def bind
      @socket.close if @socket
      @socket = UDPSocket.open
      
      @socket.setsockopt Socket::IPPROTO_IP,
                         Socket::IP_MULTICAST_TTL,
                         [1].pack('i')
      return @socket
    ensure
      ObjectSpace.define_finalizer self, Proc.new { @socket.close }
    end
    
    def puts(m)
      max = UDP.max_length
      if m.size > max
        self.puts m[0...max]
        self.puts m[max...m.size]
      else
        @socket.send(m, 0, @group, @port)
        m
      end
    end
    
  end
end