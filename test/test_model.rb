#! /usr/bin/env ruby

require 'set'

require_relative '../model/board'
require_relative '../model/otto_n_toot'
require_relative '../model/connect4'

require_relative 'mock_view'

class TestModel

    def self.test_board
        n_rows = 8
        n_cols = 7
        b = Board.new(n_rows,n_cols)
        # Board goal:
        #          :F
        #          :F
        #          :F
        #          :F
        #       :T :F
        #       :O :F
        #    :O :T :F
        # :O :T :O :F

        b.add_piece(3, :F)
        b.add_piece(3, :F)
        b.add_piece(3, :F)
        b.add_piece(3, :F)
        b.add_piece(3, :F)
        b.add_piece(3, :F)
        b.add_piece(3, :F)
        b.add_piece(3, :F)

        b.add_piece(2, :O)
        b.add_piece(2, :T)
        b.add_piece(2, :O)
        b.add_piece(2, :T)

        b.add_piece(1, :T)
        b.add_piece(0, :O)
        b.add_piece(1, :O)

        pos = b.positions
        cols = b.valid_columns
        assert(cols == (n_cols.times.to_a - [3]), 'valid_columns doesn\'t work')

        pat = b.pattern_found([:T,:T,:T,:T])
        pat2 = b.pattern_found([:T,:O,:T,:O])
        pat3 = b.pattern_found([:O,:O,:O])
        pat4 = b.pattern_found([:O,:O])
        pat5 = b.pattern_found([:F,:O,:T,:O])
        pat6 = b.pattern_found([:T,:T,:F])
        puts pos, cols, pat, pat2, pat3, pat4, pat5, pat6

        t = [
            [1, 2, 3, 4],
            [5, 6, 7, 8],
            [9,10,11,12]
        ]
        expected = Set.new([[9],[5,10],[1,6,11],[2,7,12],[3,8],[4],[1],[2,5],[3,6,9],[4,7,10],[8,11],[12]])
        idx = b.diagonal_indices(3,4)
        result = Set.new(idx.map {|d| d.map {|i,j| t[i][j]}})
        assert(result == expected, 'diagonal calculation is incorrect')
    end

    def self.test_game
        tv = MockView.new
        ont = OttoNToot.new([tv], 4,4)
        goal_board = [
            [nil,nil, :T,nil],
            [nil,nil, :O,nil],
            [nil, :O, :T,nil],
            [ :O, :T, :T, :O],
        ]

        moves = [
            [1, 0],
            [2, 1],
            [1, 1],
            [2, 2],
            [2, 2],
            [1, 2],
            [2, 2]
        ]
        winning_move = [1, 3]

        moves.each do |player_nbr, col|
            ont.make_move(player_nbr, col)
            assert(!tv.victory, 'Nobody should have won yet')
        end

        ont.make_move(*winning_move)

        vic = tv.victory
        winner = Player.new(:O, [:O,:T,:T,:O])
        assert(vic, 'someone should have won')
        assert(vic.winner == winner, 'Player 1 should have won')
        assert(tv.board == goal_board, 'Board is wrong')
        winner_positions = 4.times.map {|j| [3,j]}
        assert(vic.positions == winner_positions, 'Winning position is in the wrong place')
    end

end

TestModel.test_board
TestModel.test_game
