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

        # TODO: Come up with more appropriate value?
        return true
    end

    def set_game(game_uuid, serialized_game)
        puts 'In set game...'

        if get_game(game_uuid) != false
            puts 'Updating...' # Made it here...

            res = @games_database.query(:PROGRESS, {:uuid => game_uuid})

            puts 'Here'

            unless res.empty?
                puts 'Now here'

                @games_database.update(
                    :PROGRESS, res[0][:id], {:uuid => game_uuid, :serialized_game => serialized_game})
            else
                puts 'Record not found'
                return false
            end
        else
            puts 'Creating...'

            @games_database.create(:PROGRESS, {:uuid => game_uuid, :serialized_game => serialized_game})
        end

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