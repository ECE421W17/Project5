require 'pp' # TODO: Remove?
require 'xmlrpc/client'

require_relative 'game_client'
require_relative 'game_server'

# Just a stub object to get things to work
# TODO: Remove? Remove comment? :S
# class MockView
#     def update(positions, victory)
#     end
# end

class CLI
    def initialize(screen_name, port_number)
        puts 'In initialize'

        launch_local_game_server(screen_name, port_number)

        # TODO: Extract address to global scope
        # TODO: Wait for server to come up?...
        @client = GameClient.new({:game_server_ip => '127.0.0.1', :game_server_port => port_number})
    end

    def launch_local_game_server(screen_name, port_number)
        pid = Process.fork do
            puts 'In new process...'

            # TODO: Extract address to global scope
            gs = GameServer.new({:games_database_ip => '127.0.0.1', :games_database_port => 9000,
                :game_server_port => port_number, :screen_name => screen_name})
            gs.serve
        end

        if pid != 0
            return
        end
    end

    def process_command_command_string(command_string)
        puts "Processing command: #{command_string}"

        server_proxy = @client.proxy("gameServerHandler") 

        command_regex = /\S+/
        arguments_regex = /(\s+\S+)+/

        command = command_regex.match(command_string).to_s
        arguments = arguments_regex.match(command_string).to_s.strip

        # split_integer_args = arguments.split(" ").map { |val| val.to_i }

        case command
        when "accept-incoming-challenge"
            split_arguments = arguments.split(" ")
            if split_arguments.length != 1
                puts "ERROR: Missing argument(s)"
                return
            end

            res = server_proxy.accept_challenge(
                [MockView.new], :Connect4, split_arguments[0])
            if res.nil?
                puts "nil"
            else
                puts "non-nil"
            end
        when 'challenge-player-connect4'
            split_arguments = arguments.split(" ")
            if split_arguments.length != 1
                puts "ERROR: Missing argument(s)"
                return
            end

            tmp_view = MockView.new
            res = server_proxy.challenge_player_with_screen_name(
                [], :Connect4, split_arguments[0])
            
            res = JSON.parse(res)

            puts "Res: #{res}"

            mv = MockView.new
            res.add_view(mv)

            if res.nil?
                puts "nil"
            else
                puts "non-nil"
            end
        when "get-incoming-challenges"
            res = server_proxy.get_incoming_challenges
            pp res
        when 'list-online-players'
            res = server_proxy.get_online_players
            pp res
        else
            puts "ERROR: Unrecognized command"
        end
    end

    def run
        begin
            while true
                command_string = gets
                process_command_command_string command_string
            end
        rescue Interrupt
            puts 'Rescued'
        end
    end
end