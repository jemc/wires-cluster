
require 'wires'
require "#{File.dirname __FILE__}/cluster/udp"

module Wires
  module Cluster
    PORT  = 4567
    GROUP = "224.0.1.33"
    
    def self.listen
      @rx ||= Wires::Cluster::UDP::RX.new GROUP, PORT
      raise IOError, "Probably firewalled..." unless @rx.test!
      
      Thread.new do
        loop do
          msg = @rx.gets
          p [msg.size, msg, msg.source]
        end
      end
    end
    
  end
end