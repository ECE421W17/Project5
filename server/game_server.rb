require 'xmlrpc/server'

class CustomHandler
    def sumAndDifference(a, b)
        { "sum" => a + b, "difference" => a - b }
    end
end

class GameServer
    def initialize
        puts 'Initializing game server...'
        
        @server = XMLRPC::Server.new(8080)

        @server.add_handler("customHandler", CustomHandler.new)
    end

    def serve
        puts 'Serving'
        @server.serve
    end
end 