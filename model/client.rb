
class Client

	def initialize_pre_cond(portNumber)
		assert(IPAddress.valid? hostname, "hostname is not an ip")
		assert(portNumber.respond_to?(:to_i), "portNumber must be a integer")
		assert(portNumber > 0, "portNumber must be greater than zero")
	end

	def initialize_post_cond
	end
	
	def initialize(portNumber)

	end

	def startGame_pre_cond(mode)
		modes = ['onePlayer', 'twoPlayer']
		assert(modes.include? mode, "mode must be onePlayer or twoPlayer")
	end

	def startGame_post_cond

	end

	def startGame(mode)
	end

	def makeMove_pre_cond(col)
		assert(col.respond_to?(:to_i), "col is not an integer")
		assert(portNumber > 0, "portNumber must be greater than zero")
		assert(portNumber < 7, "portNumber must be less than 7")
	end

	def makeMove_post_cond
	end

	def make_move(col)
	end

	def saveGame_pre_cond
	end

	def saveGame_post_cond

	end

	def saveGame()

	end

	def loadGame_pre_cond(gameID)
		activeGames = getActiveGames
		assert(activeGames.include?(gameID), "gameID not exist in active games")
	end

	def loadGame_post_cond

	end

	def loadGame(gameID)

	end

	def getSaveGames_pre_cond
	end

	def getSaveGames_post_cond
	end

	def getSaveGames
	end

	def exitGame_pre_cond
	end

	def exitGame_post_cond

	end
	def exitGame

	end




end