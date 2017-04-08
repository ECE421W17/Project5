require 'xmlrpc/client'
require 'pp' # TODO: Remove

class GameClient
    def initialize
        puts 'Initializing game client...'

        @server = server = XMLRPC::Client.new3({:host => '127.0.0.1', :port => 8080}) 
    end

    def call(path, *args)
        puts "Calling... path: #{path}, args: #{args}"

        # result = @server.call("customHandler.sumAndDifference", 4, 5)
        result = @server.call(path, args[0], args[1])
        pp result
    end
end