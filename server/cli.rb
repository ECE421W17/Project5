require 'pp' # TODO: Remove?
require 'xmlrpc/client'

require_relative 'game_client'
require_relative 'game_server'

class CLI
    def initialize
        puts 'In initialize'

        launch_local_game_server

        # TODO: Extract address to global scope
        @client = GameClient.new({:game_server_ip => '127.0.0.1', :game_server_port => 8080})
    end

    def launch_local_game_server
        pid = Process.fork do
            puts 'In new process...'

            # TODO: Extract address to global scope
            gs = GameServer.new({:games_database_ip => '127.0.0.1', :games_database_port => 9000,
                :game_server_port => 8080})
            gs.serve
        end

        if pid != 0
            return
        end
    end

    def process_command_command_string(command_string)
        puts "Processing command: #{command_string}"

        command_regex = /\S+/
        arguments_regex = /(\s+\S+)+/

        command = command_regex.match(command_string).to_s
        arguments = arguments_regex.match(command_string).to_s.strip

        split_integer_args = arguments.split(" ").map { |val| val.to_i }

        res = @client.call(command, *split_integer_args)
        pp res
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