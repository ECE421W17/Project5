require 'xmlrpc/client'
require 'pp'

# server = XMLRPC::Client.new2("http://xmlrpc-c.sourceforge.net/api/sample.php")
# result = server.call("sample.sumAndDifference", 5, 3)
# pp result

server = XMLRPC::Client.new3({:host => '127.0.0.1', :port => 8080})
result = server.call("customHandler.sumAndDifference", 4, 5)
pp result