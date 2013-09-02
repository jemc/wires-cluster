
require 'wires'
require "#{File.dirname __FILE__}/cluster/udp"
require "#{File.dirname __FILE__}/cluster/json"


Wires::Cluster::UDP.max_length = 7


module Wires
  module Cluster
    PORT  = 4567
    GROUP = "224.0.1.33"
    
    class << self
    
      # Block indefinitely while receiving messages
      def listen!
        listen
        @rx_thread.join
      end
      
      # Start the UDP receiving thread (or stop it, if action==:stop)
      def listen(action=:start)
        case action
        when :start
          @rx ||= UDP::RX.new GROUP, PORT
          raise IOError, "Probably firewalled..." unless @rx.test!
          @rx_thread ||= Thread.new { _rx_loop }
        when :stop
          @rx_thread.kill; @rx_thread = nil
          @rx.close;       @rx        = nil
        end
      end
      
      # Loop through incoming messages and deploy valid firable events
      def _rx_loop
        ongoing = {}
        loop do
          msg = @rx.gets
          ongoing[msg.source] ||= ''
          ongoing[msg.source]  += msg
          
          begin
            data = _load_json(ongoing[msg.source])
            p [data, msg.source]
            ongoing[msg.source] = nil
          rescue JSON::MissingTailError
          rescue JSON::ParserError
            ongoing[msg.source] = nil
          end
          
        end
      end; private :_rx_loop
      
    end
    
  end
end
