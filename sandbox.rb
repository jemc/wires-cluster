$LOAD_PATH.unshift(File.expand_path("./lib", File.dirname(__FILE__)))
require 'wires/cluster'

tx = Wires::Cluster::UDP::TX.new "224.0.1.33", 4567


class A; end
tx.puts (JSON.dump [Wires::Event.new(55, 22, dog:true), A.new, /channel_name/])
