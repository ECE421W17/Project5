require 'securerandom'
require 'socket'
require 'test/unit/assertions'
require 'xmlrpc/server'
require 'yaml'

require_relative '../controller/controller'

include Test::Unit::Assertions

class PlayerMoveObserverFactory
    def initialize(games_database_ip, games_database_port, game_server_ip, game_server_port)
        @games_database_ip = games_database_ip
        @games_database_port = games_database_port
        @game_server_ip = game_server_ip
        @game_server_port = game_server_port
    end

    def create_player_move_observer(game_uuid, player_1_screen_name, player_2_screen_name)
        PlayerMoveObserver.new(
            @games_database_ip, @games_database_port, @game_server_ip, @game_server_port, game_uuid,
                player_1_screen_name, player_2_screen_name)
    end
end

class PlayerMoveObserver
    def initialize(games_database_ip, games_database_port, game_server_ip, game_server_port, game_uuid,
            player_1_screen_name, player_2_screen_name)
        @games_database_ip = games_database_ip
        @games_database_port = games_database_port
        @game_uuid = game_uuid
        @player_1_screen_name = player_1_screen_name
        @player_2_screen_name = player_2_screen_name

        # TODO: Interact with the game server instead of the database server directly?
        # NOTE: These parameters are unused otherwise
        @game_server_ip = game_server_ip
        @game_server_port = game_server_port
    end

    def update(game, next_player_to_move_rank)
        games_database_client = XMLRPC::Client.new3(
            {:host => @games_database_ip, :port => @games_database_port})

        serialized_game = YAML::dump(game)

        next_player_to_move = next_player_to_move_rank == 1 ?
            @player_1_screen_name : @player_2_screen_name

        games_database_client.call("gamesDatabaseServerHandler.set_game", @game_uuid, serialized_game,
            @player_1_screen_name, @player_2_screen_name, next_player_to_move)
    end
end

class RefreshClientFactory
    def initialize(game_server_ip, game_server_port)
        @game_server_ip = game_server_ip
        @game_server_port = game_server_port
    end

    def create_refresh_client(game_uuid)
        RefreshClient.new(@game_server_ip, @game_server_port, game_uuid)
    end
end

class RefreshClient
    def initialize(game_server_ip, game_server_port, game_uuid)
        @game_server_ip = game_server_ip
        @game_server_port = game_server_port
        @game_uuid = game_uuid
    end

    def get_game
        proxy = GameClient.new(
            {:game_server_ip => @game_server_ip, :game_server_port => @game_server_port})
                .proxy("gameServerHandler")

        serialized_game = proxy.get_game(@game_uuid)
        unless serialized_game == false
            return YAML::load(serialized_game)
        end

        return nil
    end
end

# Just a stub object to get things to work
class MockView
    def update(positions, victory)
        # ...
    end
end

class GameServerHandler
    # *****
    # Local functions:
    def initialize(
        games_database_client, player_move_observer_factory, refresh_client_factory, screen_name)
        _verify_initialize_pre_conditions(screen_name)
        
        @player_move_observer_factory = player_move_observer_factory
        @refresh_client_factory = refresh_client_factory

        @games_database_server_handler_proxy = games_database_client.proxy("gamesDatabaseServerHandler")
        @local_screen_name = screen_name

        @incoming_challenges = {}
        @outgoing_challenges = []

        _verify_initialize_post_conditions
    end

    # Returns a controller if challenge was successfully accepted, false otherwise
    def accept_challenge(other_screen_name)
        _verify_accept_challenge_preconditions(other_screen_name)

        game_uuid = nil
        controller = nil

        available_game_server_ips = _get_available_game_server_ips
        available_game_server_ips.each { |game_server_ip|
            ip, port = game_server_ip["address"].split(':')
            port = port.to_i

            # TODO: Catch timeout exception
            proxy = GameClient.new({:game_server_ip => ip, :game_server_port => port})
                .proxy("gameServerHandler")
            
            remote_screen_name = proxy.get_screen_name

            if remote_screen_name == @local_screen_name
                next
            end

            if remote_screen_name == other_screen_name
                if proxy.process_accepted_challenge(@local_screen_name)
                    game_uuid = @incoming_challenges[other_screen_name][:game_uuid]
                    game_type = @incoming_challenges[other_screen_name][:game_type]
                    @incoming_challenges.delete(other_screen_name)

                    mv = MockView.new
                    controller = Controller.new([mv], game_type, :TWO_PLAYER, 1)

                    player_move_observer = @player_move_observer_factory
                        .create_player_move_observer(game_uuid, @local_screen_name, other_screen_name)
                    controller.set_player_move_observer(player_move_observer)

                    refresh_client = @refresh_client_factory.create_refresh_client(game_uuid)
                    controller.set_refresh_client(refresh_client)
                end
            end
        }

        _verify_accept_challenge_postconditions

        # TODO: Change?
        return controller.nil? ? false : YAML::dump(controller) 
    end

    # Returns a controller if challenge was successfully delivered, false otherwise
    def challenge_player_with_screen_name(game_type, screen_name)
        _verify_challenge_player_with_screen_name_preconditions(screen_name)

        controller = nil
        game_uuid = SecureRandom.uuid

        available_game_server_ips = _get_available_game_server_ips
        available_game_server_ips.each { |game_server_ip|
            ip, port = game_server_ip["address"].split(':')
            port = port.to_i

            # TODO: Catch timeout exception
            # TODO: Should be storing these clients in a list, rather than reconnecting every time?
            proxy = GameClient.new({:game_server_ip => ip, :game_server_port => port})
                .proxy("gameServerHandler")

            remote_screen_name = proxy.get_screen_name

            if remote_screen_name == @local_screen_name
                next
            end

            if remote_screen_name == screen_name
                if proxy.process_challenge(@local_screen_name, game_uuid, game_type)
                    @outgoing_challenges.push(screen_name)

                    mv = MockView.new
                    controller = Controller.new([mv], game_type, :TWO_PLAYER, 2)

                    player_move_observer = @player_move_observer_factory
                        .create_player_move_observer(game_uuid, screen_name, @local_screen_name)
                    controller.set_player_move_observer(player_move_observer)

                    refresh_client = @refresh_client_factory.create_refresh_client(game_uuid)
                    controller.set_refresh_client(refresh_client)

                    break
                end
            end
        }

        _verify_challenge_player_with_screen_name_postconditions

        return controller.nil? ? false : YAML::dump(controller)
    end

    def get_game(game_uuid)
        game = @games_database_server_handler_proxy.get_game(game_uuid)
        return game.nil? ? false : game
    end

    def get_incoming_challenges
        return @incoming_challenges.nil? ? false : @incoming_challenges
    end

    def get_online_players
        players = []

        available_game_server_ips = _get_available_game_server_ips
        available_game_server_ips.each { |game_server_ip|
            ip, port = game_server_ip["address"].split(':')
            port = port.to_i

            # TODO: Catch timeout exception
            proxy = GameClient.new({:game_server_ip => ip, :game_server_port => port})
                .proxy("gameServerHandler")
            players.push(proxy.get_screen_name)
        }

        return players
    end
    # *****

    # *****
    # Remote functions:
    def get_screen_name
        return @local_screen_name.nil? ? false : @local_screen_name
    end

    def process_challenge(other_screen_name, game_uuid, game_type)
        unless !@incoming_challenges.has_key?(other_screen_name)
            return false
        end

        @incoming_challenges[other_screen_name] = {:game_uuid => game_uuid, :game_type => game_type}

        return true
    end

    def get_top_n_player(n)
        @games_database_server_handler_proxy.top_players(n)
    end

    def history(player)
        @games_database_server_handler_proxy.history(player)
    end

    def process_accepted_challenge(other_screen_name)
        unless @outgoing_challenges.include? other_screen_name
            return false
        end

        @outgoing_challenges.delete(other_screen_name)

        return true
    end
    # *****


    def _get_available_game_server_ips
        @games_database_server_handler_proxy.get_game_server_ips
    end

    def _verify_initialize_pre_conditions(screen_name)
        assert(!screen_name.nil?, 'Screen name cannot be nil')
        assert(!screen_name.empty?, 'Screen name cannot be empty')

        # TODO: Verify that the screen name is unique among the other servers?
    end

    def _verify_initialize_post_conditions
    end

    def _verify_challenge_player_with_screen_name_preconditions(screen_name)
        assert(!@outgoing_challenges.include?(screen_name),
            'There is no outgoing challenge with the given player')
    end

    def _verify_challenge_player_with_screen_name_postconditions
    end

    def _verify_accept_challenge_preconditions(other_screen_name)
        assert(@incoming_challenges.include?(other_screen_name),
            'There is no incoming challenge from the given player')
    end

    def _verify_accept_challenge_postconditions
    end
end

class GameServer
    def initialize(game_server_argument_hash)
        _verify_initialize_pre_conditions(game_server_argument_hash)

        games_database_ip = game_server_argument_hash[:games_database_ip].to_s
        games_database_port = game_server_argument_hash[:games_database_port].to_i
        @game_server_ip = Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address
        @game_server_port = game_server_argument_hash[:game_server_port].to_i
        screen_name = game_server_argument_hash[:screen_name].to_s

        @games_database_client = XMLRPC::Client.new3(
            {:host => games_database_ip, :port => games_database_port})

        player_move_observer_factory = PlayerMoveObserverFactory.new(
            games_database_ip, games_database_port, @game_server_ip, @game_server_port)
        refresh_client_factory = RefreshClientFactory.new(@game_server_ip, @game_server_port)

        server_handler = GameServerHandler.new(
            @games_database_client, player_move_observer_factory, refresh_client_factory, screen_name)

        @server = XMLRPC::Server.new(@game_server_port, @game_server_ip)
        @server.add_handler(
            "gameServerHandler", server_handler)

        _verify_initialize_post_conditions
    end

    def serve
        # TODO: Ensure screen name is not already taken...
        # -> What if there are issues contacting one of the servers?
        # -> Could make the assumption (for now) that all usernames are unique
        # -> If the screen name is not unique, you could just kill the server...

        @games_database_client.call("gamesDatabaseServerHandler.register_game_server",
            "#{@game_server_ip}:#{@game_server_port}")

        begin
            @server.serve
        ensure
            @games_database_client.call("gamesDatabaseServerHandler.unregister_game_server",
                "#{@game_server_ip}:#{@game_server_port}")
        end
    end

    def _verify_initialize_pre_conditions(game_server_argument_hash)
        assert(game_server_argument_hash.has_key?(:games_database_ip),
            'No Games Database IP address specified')
        assert(game_server_argument_hash.has_key?(:games_database_port),
            'No Games Database port address specified')
        assert(game_server_argument_hash.has_key?(:game_server_port),
            'No Game Server port address specified')
        assert(game_server_argument_hash.has_key?(:screen_name),
            'No screen name specified')

        assert(game_server_argument_hash[:games_database_ip].respond_to? :to_s,
            'The given Games Database IP cannot be converted to a string')
        assert(game_server_argument_hash[:games_database_port].respond_to? :to_i,
            'The given Games Database port number cannot be converted to an integer')
        assert(game_server_argument_hash[:game_server_port].respond_to? :to_i,
            'The given Game Server port number cannot be converted to an integer')
        assert(game_server_argument_hash[:games_database_port].respond_to? :to_s,
            'The given screen name cannot be converted to a string')
    end

    def _verify_initialize_post_conditions
    end
end 