$LOAD_PATH.unshift(File.expand_path("./lib", File.dirname(__FILE__)))
require 'wires'
require 'wires/cluster'

rx = UDP::RX.new "224.0.1.33", 4567
raise IOError, "Probably firewalled..." unless rx.test!

loop do
  msg = rx.gets
  p [msg.size, msg, msg.source]
end
