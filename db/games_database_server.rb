require 'xmlrpc/server'

require_relative 'games_database'

class GamesDatabaseServerHandler
    def initialize
        @games_database = GamesDatabase.new
    end

    def get_game_server_ips
        @games_database.available_servers
    end

    def register_game_server(game_server_address)
        @games_database.register_game_server(game_server_address)

        # TODO: Come up with more appropriate value?
        return true
    end

    def unregister_game_server(game_server_address)
        @games_database.remove_game_server(game_server_address)

        # TODO: Come up with more appropriate value?
        return true
    end
end

class GamesDatabaseServer
    def initialize
        @server = XMLRPC::Server.new(9000)
        @server.add_handler("gamesDatabaseServerHandler", GamesDatabaseServerHandler.new)
    end

    def serve
        @server.serve
    end
end