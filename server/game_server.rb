require 'test/unit/assertions'
require 'xmlrpc/server'

include Test::Unit::Assertions

# TODO: Implement
class GameServerHandler
    # *****
    # Local functions:
    def initialize(games_database_client, screen_name)
        @games_database_server_handler_proxy = games_database_client.proxy("gamesDatabaseServerHandler")
        @screen_name = screen_name
        @incoming_challenges = []
        @outgoing_challenges = {}
    end

    # Returns true if challenge successfully delivered, false otherwise
    def challenge_player_with_screen_name(screen_name, game_type)
        # Find the server with that screen name (if it exists - what if it doesn't')
        # Call the RPC function

        # TODO: Move these preliminary checks to pre-conditions
        unless @outgoing_challenges.has_key?(screen_name)
            # TODO: Raise exception instead?
            return false
        end
        
        available_game_server_ips = _get_available_game_server_ips
        available_game_server_ips.each { |game_server_ip|
            ip, port = game_server_ip.split(':')
            port = port.to_i

            # TODO: Catch timeout exception
            # TODO: Should REALLY be storing these clients in a list, rather than reconnecting every time
            proxy = GameClient.new({:game_server_ip => ip, :game_server_port => port})
                .proxy("gameServerHandler")
            if proxy.get_screen_name == screen_name
                if proxy.process_challenge(@screen_name)
                    @outgoing_challenges[screen_name] = game_type
                    return true
                end
            end
        }

        return false
    end

    def get_challenges
        @incoming_challenges
    end

    # Returns true if challenge was successfully accepted, false otherwise
    def accept_challenge(other_screen_name)
        unless @incoming_challenges.include? other_screen_name
            # TODO: Raise exception instead?
            return false
        end

        available_game_server_ips = _get_available_game_server_ips
        available_game_server_ips.each { |game_server_ip|
            ip, port = game_server_ip.split(':')
            port = port.to_i

            # TODO: Catch timeout exception
            proxy = GameClient.new({:game_server_ip => ip, :game_server_port => port})
                .proxy("gameServerHandler")
            if proxy.get_screen_name == screen_name
                if proxy.process_accepted_challenge(@screen_name)
                    @incoming_challenges.delete(other_screen_name)

                    # TODO: ... Something... Set up game

                    return true
                end
            end
        }
    end

    def make_move(game_id, column_id)

    end
    # *****

    # *****
    # Remote functions:
    def get_screen_name
        @screen_name
    end

    def process_challenge(other_screen_name)
        if @incoming_challenges.include? other_screen_name
            return false
        end

        @incoming_challenges.push(other_screen_name)
        return true
    end

    def process_accepted_challenge(other_screen_name)
        unless @outgoing_challenges.has_key? other_screen_name
            return false
        end

        game_type = @outgoing_challenges[other_screen_name]

        # TODO: ... Something... Set up game

        return true
    end
    # *****

    def _get_available_game_server_ips
        @games_database_server_handler_proxy.get_game_server_ips
    end

    # TODO: Remvoe? Uneeded?
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
        # TODO: Ensure screen name is not already taken...
        # -> What if there are issues contacting one of the servers?
        # -> Could make the assumption (for now) that all usernames are unique
        # -> If the screen name is not unique, you could just kill the server...

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