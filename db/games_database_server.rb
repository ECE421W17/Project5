require 'socket'
require 'xmlrpc/server'

require_relative 'games_database'

class GamesDatabaseServerHandler
    def initialize
        @games_database = GamesDatabase.new
    end

    def get_game(game_uuid)
        res = @games_database.query(:PROGRESS, {:uuid => game_uuid})

        unless !res.empty?
            return false
        end

        return res[0][:serialized_game]
    end

    def get_game_server_ips
        @games_database.available_servers
    end

    def games_won_by(screen_name)
        res = @games_database.games_won_by(screen_name)
        return res.nil? ? false : res
    end

    def query(table, query_hash)
        converted_query_hash = _convert_hash_keys_to_symbols(query_hash)

        return @games_database.query(table.to_sym, converted_query_hash)
    end

    def register_game_server(game_server_address)
        @games_database.register_game_server(game_server_address)

        # TODO: Add verification?
        return true
    end

    def set_game(game_uuid, serialized_game, player_1_screen_name, player_2_screen_name,
        next_player_to_move)
        if get_game(game_uuid) != false
            res = @games_database.query(:PROGRESS, {:uuid => game_uuid})

            unless res.empty?
                @games_database.update(
                    :PROGRESS, res[0][:id], {:uuid => game_uuid, :serialized_game => serialized_game,
                        :p1 => player_1_screen_name, :p2 => player_2_screen_name,
                            :next_player_to_move => next_player_to_move})
            else
                return false
            end
        else
            @games_database.create(:PROGRESS, {:uuid => game_uuid, :serialized_game => serialized_game,
                        :p1 => player_1_screen_name, :p2 => player_2_screen_name,
                            :next_player_to_move => next_player_to_move})
        end

        return true
    end

    def top_players(n)
        res = @games_database.top_players(n)

        contains_non_nil_values = res.any? { |value| !value.nil? }

        return contains_non_nil_values ? res : false
    end

    def unregister_game_server(game_server_address)
        @games_database.remove_game_server(game_server_address)

        # TODO: Add verification?
        return true
    end

    def _convert_hash_keys_to_symbols(hash)
        Hash[hash.map { |key, value| [key.to_sym, value] }]
    end
end

class GamesDatabaseServer
    def initialize(port)
        local_ip_address = Socket.ip_address_list.find { |ai|
            ai.ipv4? && !ai.ipv4_loopback? }.ip_address

        puts "IP address: #{local_ip_address}"
        
        @server = XMLRPC::Server.new(port, local_ip_address)
        @server.add_handler("gamesDatabaseServerHandler", GamesDatabaseServerHandler.new)
    end

    def serve
        @server.serve
    end
end
