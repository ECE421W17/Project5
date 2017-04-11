require 'test/unit/assertions'

require_relative '../model/game'
require_relative '../model/connect4'
require_relative '../model/otto_n_toot'

include Test::Unit::Assertions

class Controller

    attr_accessor :next_player

    def check_class_invariants
        assert_not_empty(@views, 'There must be a view')
        assert(@game, 'The controller must have a game')
    end

    def initialize(views, game_type, player_rank)
        @player_rank = player_rank
        @views = views
        game_mode = '2Player'
        @game = game_type == :Connect4 ?
            Connect4.new(views = @views, mode = game_mode) :
            OttoNToot.new(views = @views, mode = game_mode)
        @next_player = 1
        views.each {|v| add_view(v)}
        check_class_invariants
    end

    def add_view(new_view)
        @game.add_observer(new_view)
        check_class_invariants
    end

    # Views call this method in their event handlers
	def player_update_model(column_number)
        player_update_model_preconditions

        @game.make_move(@next_player, column_number)
        @next_player = @player_rank == 1 ? 2 : 1;

        player_update_model_postconditions
	end

    def other_player_update_model(column_number)
        _verify_other_player_update_model_preconditions

        @game.make_move(@next_player, column_number)
        @next_player = @player_rank == 1 ? 2 : 1;

        _verify_other_player_update_model_postconditions
	end

    def _verify_initialize_preconditions(player_rank)
        assert(player_rank.respond_to? :to_i, 'Given player rank cannot be converted to an integer')
        
        player_rank_i = player_rank.to_i
        assert(rank > 0 && rank < 3, 'Player rank must be 1 or 2')
    end

    def _verify_initialize_postconditions
    end

    def _verify_player_update_model_preconditions
        assert(@next_player == @player_rank, 'Player 1 is not the next player to move')
    end

    def _verify_player_update_model_postconditions
    end

    def _verify_other_player_update_model_preconditions
        other_player_rank = @player_rank == 1 ? 2 : 1;
        assert(@next_player == other_player_rank, 'Player 2 is not the next player to move')
    end

    def _verify_other_player_update_model_postconditions
    end
end
