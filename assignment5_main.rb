require_relative './model/game'
require_relative './model/board'
require_relative './model/player'
require_relative './model/victory'
require_relative './model/connect4'
require_relative './model/otto_n_toot'
require_relative './model/virtual_player'

require 'xmlrpc/server'

require_relative 'db/games_database'

# load and start DB server
db_server = XMLRPC::Server.new(8080)
db_server.add_handler('db', GamesDatabase.new)
db_server.serve



