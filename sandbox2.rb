
require 'wires'
require 'dnssd'


module Wires
  class Jumper
    class << self
      
      def class_init
        @port = Socket.getservbyname 'blackjack' # Eventually change to 'wires'
      end
      
      def serve!
        
        begin
          @server = TCPServer.new nil, @port
        rescue Errno::EADDRINUSE => e
          puts 'Server already established...'
          return
        end
        
        DNSSD.announce @server, "wires-#{Process.pid}"
        
        @server_threads = []
        loop do
          socket = @server.accept
          @server_threads << Thread.new do
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