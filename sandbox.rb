
require_relative './udp.rb'

tx = UDP::TX.new "224.0.1.33", 4567

tx.puts 'd'*(UDP.max_length+5)

