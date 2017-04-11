# require 'json' # TODO: Remove?
require 'securerandom' # TODO: Remove?
require 'test/unit/assertions'
require 'xmlrpc/server'
require 'yaml' # TODO: Remove?

require_relative '../controller/new_controller' # TODO: Rename

include Test::Unit::Assertions

# TODO: Remove? - Try first
class PlayerMoveObserver
    def initialize(game_server_ip, game_server_port, game_uuid)
        @game_server_ip = game_server_ip
        @game_server_port = game_server_port
        @game_uuid = game_uuid
    end

    def update(column_id)
        proxy = GameClient.new(
            {:game_server_ip => @game_server_ip, :game_server_port => @game_server_port})
                .proxy("gameServerHandler")

        proxy.process_move(@game_uuid, column_id)
    end
end

class RefreshClient
    def get_game
        proxy = GameClient.new(
            {:game_server_ip => @game_server_ip, :game_server_port => @game_server_port})
                .proxy("gameServerHandler")

        proxy.process_move(@game_uuid, column_id)
    end
end

class RefreshObserver

# TODO: Remove?
class MockView
    def update(positions, victory)
        # ...
    end
end

# TODO: Implement
class GameServerHandler
    # *****
    # Local functions:
    def initialize(games_database_client, screen_name)
        _verify_initialize_pre_conditions(screen_name)

        @games_database_server_handler_proxy = games_database_client.proxy("gamesDatabaseServerHandler")
        @screen_name = screen_name

        @incoming_challenges = {}
        @outgoing_challenges = []

        @game_controller_map = {}
        @make_move_callback_map = {}

        _verify_initialize_post_conditions
    end

    # Returns a controller if challenge was successfully delivered, false otherwise
    def challenge_player_with_screen_name(views, game_type, screen_name)
    # def challenge_player_with_screen_name(views, game_type)
        # return true

        puts "Here 1"

        _verify_challenge_player_with_screen_name_preconditions(screen_name)

        puts "Here 2"

        controller = nil
        game_uuid = SecureRandom.uuid

        available_game_server_ips = _get_available_game_server_ips
        available_game_server_ips.each { |game_server_ip|
            ip, port = game_server_ip["address"].split(':')
            port = port.to_i

            puts "Here 3"

            # TODO: Catch timeout exception
            # TODO: Should be storing these clients in a list, rather than reconnecting every time?
            proxy = GameClient.new({:game_server_ip => ip, :game_server_port => port})
                .proxy("gameServerHandler")

            puts "#{@screen_name} vs. #{screen_name}"

            remote_screen_name = proxy.get_screen_name

            puts "remote: #{remote_screen_name}"

            if remote_screen_name == @screen_name
                next
            end

            if remote_screen_name == screen_name
                puts "Here 4"

                if proxy.process_challenge(@screen_name, game_uuid)
                    puts "Here 5"

                    @outgoing_challenges.push(screen_name)

                    mv = MockView.new
                    controller = Controller.new([mv], game_type, 2)

                    # controller.set_move_proxy(proxy, game_uuid)

                    controller.set_player_move_observer(PlayerMoveObserver.new(ip, port, game_uuid))

                    @make_move_callback_map[game_uuid] = lambda { |column_id|
                        puts 'In callback'

                        controller.other_player_update_model(column_id)
                    }

                    break
                end
            end
        }

        puts "Here 6"

        @game_controller_map[game_uuid] = controller

        _verify_challenge_player_with_screen_name_postconditions

        puts "Here 7"

        # return controller

        return_val = controller.nil? ? false : YAML::dump(controller)
        puts "Returning: #{return_val}"

        return return_val # TODO: Change?
    end

    def get_incoming_challenges
        @incoming_challenges
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

    # Returns a controller if challenge was successfully accepted, false otherwise
    def accept_challenge(views, game_type, other_screen_name)
        _verify_accept_challenge_preconditions(other_screen_name)

        game_uuid = nil
        controller = nil

        puts 'Here 1'

        available_game_server_ips = _get_available_game_server_ips
        available_game_server_ips.each { |game_server_ip|
            ip, port = game_server_ip["address"].split(':')
            port = port.to_i

            puts 'Here 2'

            # TODO: Catch timeout exception
            proxy = GameClient.new({:game_server_ip => ip, :game_server_port => port})
                .proxy("gameServerHandler")
            
            remote_screen_name = proxy.get_screen_name

            puts 'Here 3'

            if remote_screen_name == @screen_name
                next
            end

            puts 'Here 4'

            if remote_screen_name == other_screen_name
                puts 'Here 5'

                if proxy.process_accepted_challenge(@screen_name)
                    puts 'Here 6'

                    game_uuid = @incoming_challenges[other_screen_name]
                    @incoming_challenges.delete(other_screen_name)

                    puts 'Here 7'

                    mv = MockView.new
                    controller = Controller.new([mv], game_type, 1)

                    # class MoveObserver
                    #     def update(column_id)
                    #         available_game_server_ips = _get_available_game_server_ips
                    #         available_game_server_ips.each { |game_server_ip|
                    #             ip, port = game_server_ip["address"].split(':')
                    #             port = port.to_i

                    #             proxy = GameClient.new({:game_server_ip => ip, :game_server_port => port})
                    #                 .proxy("gameServerHandler")
                
                    #             remote_screen_name = proxy.get_screen_name

                    #             if remote_screen_name == @screen_name
                    #                 next
                    #             end

                    #             if remote_screen_name == other_screen_name
                    #                 proxy.process_move(game_uuid, column_id)
                    #             end
                    #         }
                    #     end
                    # end


                    # controller.set_move_observer(MoveObserver.new)


                    # controller.set_move_proxy(proxy, game_uuid)


                    controller.set_player_move_observer(PlayerMoveObserver.new(ip, port, game_uuid))

                    puts 'Here 8'

                    @make_move_callback_map[game_uuid] = lambda { |column_id|
                        controller.other_player_update_model(column_id)
                    }
                end
            end
        }

        puts 'Here 9'

        unless game_uuid.nil?
            @game_controller_map[game_uuid] = controller
        end

        _verify_accept_challenge_postconditions

        # return controller
        return controller.nil? ? false : YAML::dump(controller) # controller # TODO: Change?
    end
    # *****

    # *****
    # Remote functions:
    def get_screen_name
        puts "In get screen name (#{@screen_name})"

        return @screen_name
    end

    def process_challenge(other_screen_name, game_uuid)
        puts "Processing challenge"

        unless !@incoming_challenges.has_key? other_screen_name
            return false
        end

        @incoming_challenges[other_screen_name] = game_uuid

        return true
    end

    def process_accepted_challenge(other_screen_name)
        unless @outgoing_challenges.include? other_screen_name
            return false
        end

        @outgoing_challenges.delete(other_screen_name)

        return true
    end

    def process_move(game_uuid, column_id)
        unless @make_move_callback_map.include? game_uuid
            return false
        end

        @make_move_callback_map[game_uuid].call(column_id)

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

        puts 'Initializing game server...'
        
        games_database_ip = game_server_argument_hash[:games_database_ip].to_s
        games_database_port = game_server_argument_hash[:games_database_port].to_i
        @game_server_port = game_server_argument_hash[:game_server_port].to_i
        screen_name = game_server_argument_hash[:screen_name].to_s

        @games_database_client = XMLRPC::Client.new3(
            {:host => games_database_ip, :port => games_database_port})

        @server = XMLRPC::Server.new(@game_server_port)
        @server.add_handler(
            "gameServerHandler", GameServerHandler.new(@games_database_client, screen_name))

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