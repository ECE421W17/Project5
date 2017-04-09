require 'test/unit/assertions'
require 'xmlrpc/server'

include Test::Unit::Assertions

# TODO: Implement
class GameServerHandler
    def initialize(games_database_client)
        @games_database_server_handler_proxy = games_database_client.proxy("gamesDatabaseServerHandler")
    end

    # TODO: Remove
    # gameServerHandler.sumAndDifference 10 5 - test
    def sumAndDifference(a, b)
        { "sum" => a + b, "difference" => a - b }
    end

    # gameServerHandler.get_server_ips
    def get_server_ips
        # @games_database_client.call("gamesDatabase.available_servers")
        @games_database_server_handler_proxy.get_game_server_ips
    end

    # TODO: Remove comment, test
    # gameServerHandler.register_server 127.0.0.1 8080
    def register_server(game_server_ip, game_server_port)
        puts 'In register_server'

        # @games_database_client.call(
        #     "gamesDatabase.register_game_server", "#{game_server_ip}:#{game_server_port}")
        @games_database_server_handler_proxy.register_game_server(
            "#{game_server_ip}:#{game_server_port}")
    end

    # gameServerHandler.unregister_server 127.0.0.1 8080
    def unregister_server(game_server_ip, game_server_port)
        # @games_database_client.call(
        #     "gamesDatabase.remove_game_server", "#{game_server_ip}:#{game_server_port}")
        @games_database_server_handler_proxy.unregister_game_server(
            "#{game_server_ip}:#{game_server_port}")
    end

    def _verify_initialize_pre_conditions
    end

    def _verify_initialize_post_conditions
    end
end

class GameServer
    def initialize(game_server_argument_hash)
        _verify_initialize_pre_conditions(game_server_argument_hash)

        puts 'Initializing game server...'
        
        games_database_ip = game_server_argument_hash[:games_database_ip].to_s
        games_database_port = game_server_argument_hash[:games_database_port].to_i
        game_server_port = game_server_argument_hash[:game_server_port].to_i

        @games_database_client = XMLRPC::Client.new3(
            {:host => games_database_ip, :port => games_database_port})

        @server = XMLRPC::Server.new(game_server_port)
        @server.add_handler(
            "gameServerHandler", GameServerHandler.new(@games_database_client))

        _verify_initialize_post_conditions
    end

    def serve
        puts 'Serving'

        @games_database_client.call("gamesDatabaseServerHandler.register_game_server",
            "127.0.0.1:#{@game_server_port}")

        puts 'Registered'

        begin
            @server.serve
        ensure
            @games_database_client.call("gamesDatabaseServerHandler.unregister_game_server",
                "127.0.0.1:#{@game_server_port}")

            puts 'Unregistered'
        end
    end

    def _verify_initialize_pre_conditions(game_server_argument_hash)
        assert(game_server_argument_hash.has_key?(:games_database_ip),
            'No Games Database IP address specified')
        assert(game_server_argument_hash.has_key?(:games_database_port),
            'No Games Database port address specified')
        assert(game_server_argument_hash.has_key?(:game_server_port),
            'No Game Server port address specified')

        assert(game_server_argument_hash[:games_database_ip].respond_to? :to_s,
            'The given Games Database IP cannot be converted to a string')
        assert(game_server_argument_hash[:games_database_port].respond_to? :to_i,
            'The given Games Database port number cannot be converted to an integer')
        assert(game_server_argument_hash[:game_server_port].respond_to? :to_i,
            'The given Game Server port number cannot be converted to an integer')
    end

    def _verify_initialize_post_conditions
    end
end 