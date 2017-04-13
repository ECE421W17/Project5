require 'xmlrpc/client'

class GameClient
    def initialize(game_client_argument_hash)
        _verify_initialize_pre_conditions(game_client_argument_hash)
        
        game_server_ip = game_client_argument_hash[:game_server_ip].to_s
        game_server_port = game_client_argument_hash[:game_server_port].to_i

        @client = XMLRPC::Client.new3({:host => game_server_ip, :port => game_server_port})
        @client_proxy = @client.proxy("gameServerHandler")

        _verify_initialize_post_conditions
    end

    # TODO: Don't use hard-coded game type...
    def accept_challenge(screen_name)
        controller = YAML::load(@client_proxy.accept_challenge(screen_name))
        return controller == false ? nil : controller
    end

    def get_challenges
        res = @client_proxy.get_incoming_challenges
        return res == false ? nil : res
    end

    def get_online_players
        res = @client_proxy.get_online_players
        return res == false ? nil : res
    end

    def get_suspended_games
        res = @client_proxy.get_suspended_games
        return res == false ? nil : res
    end

    def issue_challenge(screen_name, game_type)
        controller = YAML::load(
            @client_proxy.challenge_player_with_screen_name(game_type, screen_name))
        
        return controller == false ? nil : controller
    end

    def proxy(path)
        @client.proxy(path)
    end

    def resume_suspended_game(game_uuid)
        controller = YAML::load(@client_proxy.resume_suspended_game(game_uuid))
        return controller == false ? nil : controller
    end

    def _verify_initialize_pre_conditions(game_client_argument_hash)
        assert(game_client_argument_hash.has_key?(:game_server_ip),
            'No Game Server IP address specified')
        assert(game_client_argument_hash.has_key?(:game_server_port),
            'No Game Server port address specified')

        assert(game_client_argument_hash[:games_server_ip].respond_to? :to_s,
            'The given Game Server IP cannot be converted to a string')
        assert(game_client_argument_hash[:game_server_port].respond_to? :to_i,
            'The given Game Server port number cannot be converted to an integer')
    end

    def _verify_initialize_post_conditions
    end
end