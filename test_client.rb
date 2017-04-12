require 'xmlrpc/client'
require 'pp'
require 'socket'

# client = XMLRPC::Client.new2("http://xmlrpc-c.sourceforge.net/api/sample.php")
# result = client.call("sample.sumAndDifference", 5, 3)
# pp result

ip_address = Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address

# client = XMLRPC::Client.new3({:host => '127.0.0.1', :port => 8080})
# 129.128.211.41
client = XMLRPC::Client.new3({:host => '129.128.211.41', :port => 50080})
result = client.call("customHandler.sumAndDifference", 4, 5)
pp result
