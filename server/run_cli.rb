require_relative 'cli'

unless ARGV.length == 2
    raise 'Missing screen name and port number command line arguments'
end

tmp1 = ARGV[0].to_s
tmp2 = ARGV[1].to_i

ARGV.clear

cli = CLI.new(tmp1, tmp2)
cli.run