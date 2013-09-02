
require 'socket'
require 'ipaddr'

module Wires
  module Cluster
    module UDP
      class << self;  attr_accessor :max_length;  end
      self.max_length = 1024 # default max payload length
      
      
      class RX
        
        def initialize(group, port, selfish:false, bind_port:nil)
          @group     = group
          @port      = port
          
          @selfish   = selfish
          @bind_port = bind_port
          
          bind
        end
        
        def bind
          @socket.close if @socket
          @socket = UDPSocket.new
          
          # Add membership to the multicast group
          @socket.setsockopt Socket::IPPROTO_IP,
                             Socket::IP_ADD_MEMBERSHIP,
                             IPAddr.new(@group).hton + IPAddr.new("0.0.0.0").hton
          
          # Don't prevent future listening peers on the same machine
          @socket.setsockopt(Socket::SOL_SOCKET,
                             Socket::SO_REUSEADDR,
                             [1].pack('i')) unless @selfish
          
          # Bind the socket to the specified port or any open port on the machine
          @socket.bind (@bind_port or Socket::INADDR_ANY), @port
          
          return @socket
        ensure # close the socket on object deconstruction
          ObjectSpace.define_finalizer self, Proc.new { @socket.close }
        end
        
        def close
          @socket.close
        end
        
        def gets
          msg, addrinfo = @socket.recvfrom(UDP.max_length)
          msg.instance_variable_set :@source, addrinfo[3].to_s+':'+addrinfo[1].to_s
          class << msg;  attr_reader :source;  end
          msg
        end
        
        def test!(message="#{self}.test!")
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
          
          tx.puts message
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
        
        def close
          @socket.close
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
  end
end