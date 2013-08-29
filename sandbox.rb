
require_relative './udp.rb'

tx = UDP::TX.new "224.0.1.33", 4567
rx = UDP::RX.new "224.0.1.33", 4567

gthr = Thread.current
passed = false
thr = Thread.new do
  p rx.gets
  passed = true
  gthr.wakeup
end
Thread.pass

tx.puts 'test'

sleep 1
thr.kill

raise IOError, "Probably firewalled..." unless passed

