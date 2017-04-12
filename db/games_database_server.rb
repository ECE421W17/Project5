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

    def register_game_server(game_server_address)
        @games_database.register_game_server(game_server_address)

        # TODO: Add verification?
        return true
    end

    def set_game(game_uuid, serialized_game)
        if get_game(game_uuid) != false
            res = @games_database.query(:PROGRESS, {:uuid => game_uuid})

            unless res.empty?
                @games_database.update(
                    :PROGRESS, res[0][:id], {:uuid => game_uuid, :serialized_game => serialized_game})
            else
                return false
            end
        else
            @games_database.create(:PROGRESS, {:uuid => game_uuid, :serialized_game => serialized_game})
        end

        return true
    end

    def unregister_game_server(game_server_address)
        @games_database.remove_game_server(game_server_address)

        # TODO: Add verification?
        return true
    end
end

class GamesDatabaseServer
    def initialize
        local_ip_address = Socket.ip_address_list.find { |ai|
            ai.ipv4? && !ai.ipv4_loopback? }.ip_address

        @server = XMLRPC::Server.new(9000, local_ip_address)
        @server.add_handler("gamesDatabaseServerHandler", GamesDatabaseServerHandler.new)
    end

    def serve
        @server.serve
    end
end