require 'xmlrpc/client'
require 'pp'
require 'socket'

client = XMLRPC::Client.new3({:host => '129.128.211.41', :port => 50080})
result = client.call("customHandler.sumAndDifference", 4, 5)
pp result
