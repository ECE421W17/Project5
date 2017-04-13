require 'test/unit/assertions'
require_relative 'player'
require_relative 'board'
include Test::Unit::Assertions

class VirtualPlayer

    ##Algorithm for computerized player
    def self.makemove(board, players, cPlayerNumber)

    	validColumn = board.valid_columns

    	if(validColumn.length == 0)
    		puts "no more available moves"
    	end

    	if(validColumn.length == 1)
    		#We have no choices
    		return validColumn[0]
    	end

    	#cPlayer => current player, player controlled by AI logic
    	#oPlayer => human player, controlled by Human
    	cPlayer = players[cPlayerNumber - 1]
    	#if cPlayerNu
    	oPlayer = nil
    	players.each do |i|
    		if i.getCategory != cPlayer.getCategory
    			oPlayer = i
    		end
    	end

    	#check is there a winning move for cPlayer
		validColumn.each do |i|
			board.add_piece(i, cPlayer.getCategory)
			winning_positions = board.pattern_found(cPlayer.getWinningPattern)
			board.remove_piece(i, cPlayer.getCategory)
			if winning_positions
				return i
			end

		end

		#No winning move, check whether a winning move for oPlayer
		validColumn.each do |i|
			board.add_piece(i, oPlayer.getCategory)
			winning_positions = board.pattern_found(oPlayer.getWinningPattern)
			board.remove_piece(i, oPlayer.getCategory)
			if winning_positions
				return i
			end
		end


		#check is the move will lead to other player to win
		validColumn.each do |i|
			board.add_piece(i, cPlayer.getCategory)
			vCol = board.valid_columns
			vCol.each do |j|
				board.add_piece(j, oPlayer.getCategory)
				winning_positions = board.pattern_found(oPlayer.getWinningPattern)
				board.remove_piece(j, oPlayer.getCategory)
				if !winning_positions
					board.remove_piece(i, cPlayer.getCategory)
					return i
				end
			end
			board.remove_piece(i, cPlayer.getCategory)
		end
		return validColumn[validColumn.length/2]
    end
end
