require 'pp'
require 'xmlrpc/client'
require 'yaml' # TODO: Remove?

require_relative 'game_client'
require_relative 'game_server'

class CLI
    def initialize(screen_name, port_number)
        launch_local_game_server(screen_name, port_number)

        # TODO: Extract address to global scope
        # TODO: Wait for server to come up?...
        @client = GameClient.new({:game_server_ip => '127.0.0.1', :game_server_port => port_number})
    end

    def launch_local_game_server(screen_name, port_number)
        pid = Process.fork do
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
        command_regex = /\S+/
        arguments_regex = /(\s+\S+)+/

        command = command_regex.match(command_string).to_s
        arguments = arguments_regex.match(command_string).to_s.strip

        case command
        when "accept-challenge"
            split_arguments = arguments.split(" ")
            if split_arguments.length != 1
                puts "ERROR: Missing argument(s)"
                return
            end

            @tmp_controller = @client.accept_challenge(split_arguments[0], :Connect4)
        when 'challenge-connect4'
            split_arguments = arguments.split(" ")
            if split_arguments.length != 1
                puts "ERROR: Missing argument(s)"
                return
            end

            @tmp_controller = @client.issue_challenge(split_arguments[0], :Connect4) 
        when "list-challenges"
            res = @client.get_challenges
            pp res
        when 'list-players'
            res = @client.get_online_players
            pp res
        when 'make-move'
            unless !@tmp_controller.nil?
                raise "ERROR: Controller not initialized"
            end

            split_arguments = arguments.split(" ")
            if split_arguments.length != 1
                puts "ERROR: Missing argument(s)"
                return
            end

            column_id = split_arguments[0].to_i

            @tmp_controller.player_update_model(column_id)
        when 'print-board'
            unless !@tmp_controller.nil?
                raise "ERROR: Controller not initialized"
            end

            puts @tmp_controller.get_game.get_board.to_s
        when 'refresh-board'
            unless !@tmp_controller.nil?
                raise "ERROR: Controller not initialized"
            end

            puts @tmp_controller.refresh
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
            puts 'Exiting'
        end
    end
end