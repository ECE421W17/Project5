require 'test/unit/assertions'

require_relative '../model/game'
require_relative '../model/connect4'
require_relative '../model/otto_n_toot'

include Test::Unit::Assertions

class Controller
    GAME_MODES = [:ONE_PLAYER, :TWO_PLAYER]

    attr_accessor :next_player

    def check_class_invariants
        assert_not_empty(@views, 'There must be a view')
        assert(@game, 'The controller must have a game')
    end

    def initialize(views, game_type, game_mode, player_rank)
        _verify_initialize_preconditions(game_mode, player_rank)

        @game_mode = game_mode
        @player_rank = player_rank
        @views = views

        game_mode = game_mode == :ONE_PLAYER ? '1Player' : '2Player'

        @game = game_type == :Connect4 ?
            Connect4.new(views = @views, mode = game_mode) :
            OttoNToot.new(views = @views, mode = game_mode)
        @next_player = 1
        views.each {|v| add_view(v)}
        check_class_invariants

        _verify_initialize_postconditions
    end

    def add_view(new_view)
        @game.add_observer(new_view)
        check_class_invariants
    end

    def get_game
        @game
    end

    # Views call this method in their event handlers
	def player_update_model(column_number)
        _verify_player_update_model_preconditions

        if @game.board.column_full?(column_number)
          return false
        end

        @game.make_move(@next_player, column_number)
        if @game.victory != nil
          unless @player_move_observer.nil?
              @player_move_observer.update(@game)
          end

          _verify_player_update_model_postconditions
          return true
        end

        @next_player = @player_rank == 1 ? 2 : 1

        if @game_mode == :ONE_PLAYER && @next_player == 2
          @game.make_move(@next_player, column_number)
          @next_player = @next_player == 1 ? 2 : 1
        end

        unless @player_move_observer.nil?
            @player_move_observer.update(@game, @next_player)
        end

        _verify_player_update_model_postconditions
	end

    def refresh
        _verify_refresh_preconditions

        updated_game = @refresh_client.get_game

        if updated_game.nil?
            return
        end

        unless @game.get_board == updated_game.get_board
            @game.set_board(updated_game.get_board)
            @next_player = @next_player == 1 ? 2 : 1
        end

        @game.notify_observers(@game.get_board.positions, @game.winner)
        puts "refreshing\n"

        _verify_refresh_postconditions
    end

    def set_player_move_observer(player_move_observer)
        @player_move_observer = player_move_observer
    end

    def set_rank(player_rank)
        @player_rank = player_rank
    end

    def set_refresh_client(refresh_client)
        @refresh_client = refresh_client
    end

    def _verify_initialize_preconditions(game_mode, player_rank)
        assert(player_rank.respond_to? :to_i, 'Given player rank cannot be converted to an integer')

        player_rank_i = player_rank.to_i
        assert(player_rank_i > 0 && player_rank_i < 3, 'Player rank must be 1 or 2')

        assert(
            GAME_MODES.include?(game_mode),
                'Game mode is not recognized (must be :ONE_PLAYER or :TWO_PLAYER)')
    end

    def _verify_initialize_postconditions
    end

    def _verify_player_update_model_preconditions
        assert(@next_player == @player_rank, 'Player 1 is not the next player to move')
    end

    def _verify_player_update_model_postconditions
    end

    def _verify_refresh_preconditions
        assert(!@refresh_client.nil?, 'Refresh client cannot be nil')
    end

    def _verify_refresh_postconditions
    end
end
