
require 'dnssd'


def find_and_bind
  service = nil
  DNSSD.browse! '_blackjack._tcp' do |reply|
    DNSSD.resolve! reply do |reply|
      service = reply
      break
    end
    break
  end

  service ? (TCPSocket.new service.target, service.port) : nil
end

p socket = (find_and_bind)

# socket.puts 'hello'