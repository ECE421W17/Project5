require 'xmlrpc/server'
require 'socket'

class CustomHandler
    def sumAndDifference(a, b)
        { "sum" => a + b, "difference" => a - b }
    end
end

ip_address = Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address

s = XMLRPC::Server.new(50500, ip_address)
s.add_handler("customHandler", CustomHandler.new)

s.serve
