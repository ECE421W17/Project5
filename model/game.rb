require 'test/unit/assertions'

require_relative 'player'
require_relative 'board'
require_relative 'victory'
require_relative 'virtual_player'

include Test::Unit::Assertions

class Game

    include Observable
    # Game passes the following information to its observers:
    # 1. The board positions, as a 2-dimensional array of nils and symbols
    # 2. A Victory object with the winner. If there is no winner yet, this is nil

    def categories
        []
    end

    def player_patterns
        []
    end

    def default_n_rows
        0
    end

    def default_n_cols
        0
    end

    def check_class_invariants
        assert(@board, 'A game must have a board')
        assert(@players && !@players.empty?, 'A game must have players')
    end

    def initialize_pre_cond(player_categories)
        player_categories.each_with_index do |c, i|
            assert(categories.include?(c), "The category for player #{i} is not valid")
        end
    end

    def initialize_post_cond
        assert(player_patterns.length == @players.length, 'Wrong number of players')
        @players.zip(player_patterns).each do |player, pattern|
            assert(player.winning_pattern == pattern, 'Player 1 must have the right winning pattern')
        end
    end


    def initialize(views, mode = "2Player", n_rows = default_n_rows, n_cols = default_n_cols, player_categories = categories, ai = "VirtualPlayer")
        initialize_pre_cond(player_categories)
        @board = Board.new(n_rows, n_cols)

        #Default as two player
        modes = [false, false]
        if mode == "1Player"
            modes = [false, true]
        end

        @players = player_categories.zip(player_patterns, modes).map do |cat, pattern, isVirtual|
            Player.new(cat, pattern, isVirtual)
        end
        @ai = Object.const_get(ai)

        initialize_post_cond
        check_class_invariants
    end

    def get_board
        @board
    end

    def make_move_pre_cond(player_number, col)
        index = player_number - 1
        assert(0 <= index && index < @players.length, "There is no player #{player_number}")
        assert(@board.valid_columns.include?(col), "Column #{col} is not valid")
    end

    def make_move_post_cond
    end

    def make_move(player_number, col)
        make_move_pre_cond(player_number, col)
        player = @players[player_number - 1]
        if(player.isVirtual)
            begin
                col = @ai.makemove(@board, @players, player_number)
            rescue
                puts "Invalid Algorithm Name"
                raise "Invalid Algorithm Name"
            end
        end
        @board.add_piece(col, player.category)

        changed
        notify_observers(@board.positions, winner)

        make_move_post_cond
    end

    def set_board(new_board)
        @board = new_board
    end

    def winner
        # Determine if any player has won (its winning condition is met)
        # and return the corresponding Victory object if yes, nil otherwise
        @players.each do |player|
            winning_positions = @board.pattern_found(player.winning_pattern)
            if winning_positions
                return Victory.new(player, winning_positions)
            end
        end

        nil
    end

end
