require 'ipaddress'

class Server

	def initialize_pre_cond(hostname, portNumber)
		assert(IPAddress.valid? hostname, "hostname is not an ip")
		assert(portNumber.respond_to?(:to_i), "portNumber must be a integer")
		assert(portNumber > 0, "portNumber must be greater than zero")
	end

	def initialize_post_cond
	end

	def initialize(hostname, portNumber)
	end

	def startGame_pre_cond(mode)
		modes = ['onePlayer', 'twoPlayer']
		assert(modes.include? mode, "mode must be onePlayer or twoPlayer")
	end

	def startGame_post_cond

	end

	def startGame(mode, player1)
	end

    def challenge_pre_cond(player2)
    	activePlayers = listActivePlayers()
    	assert(activePlayers.include? player2, "player2 not online")
    end

    def challenge_post_cond
    end

	def challenge(player2)
	end

    def update_pre_cond
    end

    def update_post_cond
    end

	def update()
	end

    def listActivePlayers_pre_cond
    end

    def listActivePlayers_post_cond
    end
	def listActivePlayers()

	end

	def displaySummary_pre_cond(playerID, userList)
		assert(userList.include? playerID, "playerID must exist in databse")
	end

	def displaySummary_post_cond
	end

	def displaySummary(playerID)

	end
end