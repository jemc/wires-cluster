
require 'wires'
require "#{File.dirname __FILE__}/cluster/udp"

# For now, must require in this order
# to avoid active_support wrecking json/add/core
require 'active_support/json'
require 'json/add/core'


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
        
        @rx ||= Wires::Cluster::UDP::RX.new GROUP, PORT
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
    
    
    class UnserializableObject
      def to_s; '<UnserializableObject>'; end
      def inspect; to_s; end
      
      def as_json(opt=nil)
        { json_class:self.class.name }
      end
      
      def self.json_create(data)
        self.new
      end
    end
    
  end
  
  # Reopen Event to specify serialization methodology
  class Event
    def as_json(*serialization_args)
      { json_class:self.class.name,
        args:[*@args, **@kwargs] }
    end
    
    def self.json_create(data)
      self.new(*data['args'])
    end
  end
  
  
end

class Object
  def as_json(opt=nil)
    Wires::Cluster::UnserializableObject.new.as_json
  end
  
  def self.json_create(data)
    Wires::Cluster::UnserializableObject.new
  end
end