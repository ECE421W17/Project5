require_relative 'games_database_server'

unless ARGV.length == 1
  raise 'Missing argument; the port must be specified'
end

tmp1 = ARGV[0].to_i

gdbs = GamesDatabaseServer.new(tmp1)
gdbs.serve
