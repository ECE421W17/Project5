require 'xmlrpc/client'

require_relative 'game_client'
require_relative 'game_server'

class CLI
    def initialize
        puts 'In initialize'

        launch_local_game_server

        @client = GameClient.new
    end

    def launch_local_game_server
        pid = Process.fork do
            puts 'In new process...'

            gs = GameServer.new
            gs.serve
        end
    end

    def process_command_command_string(command_string)
        puts "Processing command: #{command_string}"

        command_regex = /\S+/
        arguments_regex = /(\s+\S+)+/

        command = command_regex.match(command_string).to_s
        arguments = arguments_regex.match(command_string).to_s.strip

        puts 'Meh'

        puts "Command: #{command}"
        puts "Arguments: #{arguments}"

        tmp = arguments.split(" ")
        puts tmp.to_s

        split_integer_args = tmp.map { |val| val.to_i }
        puts split_integer_args.to_s

        puts 'Here'

        @client.call(command, split_integer_args[0], split_integer_args[1])

        puts 'And here'

        case command_string
        when 'create-server'
            puts 'Creating server'
        when 'ping-server'
            puts 'Pinging server'
        when 'ping-db' # ?
            puts 'Pinging db'
        when 'send-match-request'
            puts 'Sending match request'
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

cli = CLI.new
cli.run