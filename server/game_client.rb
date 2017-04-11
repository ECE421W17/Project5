require 'xmlrpc/client'

class GameClient
    def initialize(game_client_argument_hash)
        _verify_initialize_pre_conditions(game_client_argument_hash)
        
        puts 'Initializing game client...'

        game_server_ip = game_client_argument_hash[:game_server_ip].to_s
        game_server_port = game_client_argument_hash[:game_server_port].to_i

        @client = XMLRPC::Client.new3({:host => game_server_ip, :port => game_server_port})

        _verify_initialize_post_conditions
    end

    def call(path, *args)
        puts "Calling... path: #{path}, args: #{args}"
        
        @client.call(path, *args)
    end

    def proxy(path)
        @client.proxy(path)
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