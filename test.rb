require 'xmlrpc/client'
require 'pp'

client = XMLRPC::Client.new2("http://xmlrpc-c.sourceforge.net/api/sample.php")
result = client.call("sample.sumAndDifference", 5, 3)
pp result