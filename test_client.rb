require 'xmlrpc/client'
require 'pp'

# client = XMLRPC::Client.new2("http://xmlrpc-c.sourceforge.net/api/sample.php")
# result = client.call("sample.sumAndDifference", 5, 3)
# pp result

client = XMLRPC::Client.new3({:host => '127.0.0.1', :port => 8080})
result = client.call("customHandler.sumAndDifference", 4, 5)
pp result