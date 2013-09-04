$LOAD_PATH.unshift(File.expand_path("./lib", File.dirname(__FILE__)))
require 'wires/cluster'

on :event, 'channel' do |e|
  p [e, e.cluster_source]
end

Wires::Hub.run
Wires::Cluster.listen!

Wires::Hub.kill
