
require 'wires'
require 'dnssd'


module Wires
  class Server
    class << self
      
      def class_init
        @port = Socket.getservbyname 'blackjack' # Eventually change to 'wires'
      end
      
      def serve!
        
        server = TCPServer.new nil, @port
        DNSSD.announce server, "wires-#{Process.pid}"
        
        Thread.new do
          loop do
            socket = server.accept
            peeraddr = socket.peeraddr
            puts "Connection from %s:%d" % socket.peeraddr.values_at(2, 1)
          end
        end
        
      end
      
    end
    
    class_init
    Wires::Hub.before_run { serve! }

  end
end

Wires::Hub.run

loop do
  sleep 1
end