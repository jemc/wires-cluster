
require_relative './udp.rb'

rx = UDP::RX.new "224.0.1.33", 4567

loop do
  msg = rx.gets
  p [msg.size, msg, msg.source]
end
