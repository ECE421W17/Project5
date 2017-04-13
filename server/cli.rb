require 'pp'
require 'socket'
require 'xmlrpc/client'
require 'yaml' # TODO: Remove?

require_relative '../db/games_database_client' # TODO: Remove?
require_relative 'game_client'
require_relative 'game_server'

class CLI
    def initialize(screen_name, games_database_server_ip, games_database_server_port, game_server_port)
        launch_local_game_server(
            screen_name, games_database_server_ip, games_database_server_port, game_server_port)

        # TODO: Extract address to global scope
        # TODO: Wait for server to come up?...

        @local_ip_address =
            Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address

        @client = GameClient.new(
            {:game_server_ip => @local_ip_address, :game_server_port => game_server_port})

        @games_database_client = GamesDatabaseClient.new(
            {:games_database_server_ip => games_database_server_ip,
                :games_database_server_port => games_database_server_port})
    end

    def launch_local_game_server(screen_name, games_database_server_ip, games_database_server_port, game_server_port)
        pid = Process.fork do
            # TODO: Extract address to global scope
            gs = GameServer.new(
                {:games_database_ip => games_database_server_ip,
                    :games_database_port => games_database_server_port,
                        :game_server_port => game_server_port, :screen_name => screen_name})
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

            @tmp_controller = @client.accept_challenge(split_arguments[0])
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
        when 'list-suspended'
            res = @client.get_suspended_games
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

            pp @tmp_controller.get_game.get_board.to_s
        when 'refresh-board'
            unless !@tmp_controller.nil?
                raise "ERROR: Controller not initialized"
            end

            @tmp_controller.refresh
        when 'resume-suspended'
            split_arguments = arguments.split(" ")
            if split_arguments.length != 1
                puts "ERROR: Missing argument(s)"
                return
            end

            @tmp_controller = @client.resume_suspended_game(split_arguments[0])
        # TODO: Remove command - testing
        when 'test'
            # res = @games_database_client.query(
            #     :PROGRESS, {:uuid => '3a6b151d-d0fa-46c3-8d6a-145059a27522'})
            # res = @games_database_client.top_players(1)
            res = @games_database_client.games_won_by('a')
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
            puts 'Exiting'
        end
    end
end