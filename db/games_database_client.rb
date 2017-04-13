require 'xmlrpc/client'

class GamesDatabaseClient
    def initialize(games_database_client_argument_hash)
        _verify_initialize_pre_conditions(games_database_client_argument_hash)
        
        games_database_server_ip = games_database_client_argument_hash[:games_database_server_ip].to_s
        games_database_server_port =
            games_database_client_argument_hash[:games_database_server_port].to_i

        @client = XMLRPC::Client.new3(
            {:host => games_database_server_ip, :port => games_database_server_port})
        @client_proxy = @client.proxy("gamesDatabaseServerHandler")

        _verify_initialize_post_conditions
    end

    def games_won_by(screen_name)
        @client_proxy.games_won_by(screen_name)
    end

    def proxy(path)
        @client.proxy(path)
    end

    def query(table, query_hash)
        @client_proxy.query(table, query_hash)
    end

    def top_players(n)
        @client_proxy.top_players(n)
    end

    def _verify_initialize_pre_conditions(games_database_client_argument_hash)
        assert(games_database_client_argument_hash.has_key?(:games_database_server_ip),
            'No Game Server IP address specified')
        assert(games_database_client_argument_hash.has_key?(:games_database_server_port),
            'No Game Server port address specified')

        assert(games_database_client_argument_hash[:games_server_ip].respond_to? :to_s,
            'The given Game Server IP cannot be converted to a string')
        assert(games_database_client_argument_hash[:games_database_server_port].respond_to? :to_i,
            'The given Game Server port number cannot be converted to an integer')
    end

    def _verify_initialize_post_conditions
    end
end