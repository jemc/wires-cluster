$LOAD_PATH.unshift(File.expand_path("./lib", File.dirname(__FILE__)))
require 'wires/cluster'

Wires::Hub.run
Wires::Cluster.spout

fire :event, 'channel'
