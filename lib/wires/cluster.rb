
require 'wires'
require "#{File.dirname __FILE__}/cluster/udp"
require "#{File.dirname __FILE__}/cluster/json"


module Wires
  module Cluster
    PORT  = 4567
    GROUP = "224.0.1.33"
    
    def self.listen!
      self.listen
      @rx_thread.join
    end
    
    def self.listen(action=:start)
      
      case action
      when :start
        
        @rx ||= UDP::RX.new GROUP, PORT
        raise IOError, "Probably firewalled..." unless @rx.test!
        
        @rx_thread ||= Thread.new do
          loop do
            msg = @rx.gets
            p [JSON.load(msg), msg.source]
          end
        end
      
      when :stop
        @rx_thread.kill; @rx_thread = nil
        @rx.close;       @rx        = nil
      end
      
    end
  end
end
