$LOAD_PATH.unshift(File.expand_path("./lib", File.dirname(__FILE__)))
require 'wires'
require 'wires/cluster'

tx = UDP::TX.new "224.0.1.33", 4567

tx.puts 'something'
tx.puts 'something_else'
