require 'xmlrpc/server'

class CustomHandler
    def sumAndDifference(a, b)
        { "sum" => a + b, "difference" => a - b }
    end
end

s = XMLRPC::Server.new(8080)
s.add_handler("customHandler", CustomHandler.new)

s.serve
