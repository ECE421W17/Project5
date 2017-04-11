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
        _verify_initialize_preconditions(player_rank)

        @player_rank = player_rank
        @views = views
        game_mode = '2Player'
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

        @game.make_move(@next_player, column_number)
        @next_player = @player_rank == 1 ? 2 : 1;

        # unless @update_model_proxy_lambda.nil?
        #     @update_model_proxy_lambda.call(column_number)
        # end

        # unless @move_observer.nil?
        #     @move_observer.update(column_number)
        # end

        # unless @move_proxy.nil? || @game_uuid.nil?
        #     @move_proxy.proxy.process_move(@game_uuid, column_id)
        # end

        unless @player_move_observer.nil?
            @player_move_observer.update(@game)
        end

        _verify_player_update_model_postconditions
	end

    def other_player_update_model(column_number)
        puts 'In other player update model...'

        _verify_other_player_update_model_preconditions

        @game.make_move(@next_player, column_number)

        puts 'UPDATED'
        puts @game.get_board.to_s

        @next_player = @player_rank == 1 ? 2 : 1;

        _verify_other_player_update_model_postconditions
	end

    def refresh
        _verify_refresh_preconditions
        
        updated_game = @refresh_client.get_game

        puts updated_game.get_board.to_s

        @game = updated_game

        _verify_refresh_postconditions
    end

    # TODO: Remove?
    def set_move_observer(move_observer)
        @move_observer = move_observer
    end

    # TODO: Accept uuid in init.; more appropriate there
    def set_move_proxy(move_proxy, game_uuid)
        @game_uuid = game_uuid
        @move_proxy = move_proxy
    end

    # WORKED
    def set_player_move_observer(player_move_observer)
        @player_move_observer = player_move_observer
    end

    # TODO: Remove?
    def set_update_model_proxy_lambda(update_model_proxy_lambda)
        _verify_set_update_model_proxy_lambda_preconditions(update_model_proxy_lambda)

        @update_model_proxy_lambda = update_model_proxy_lambda

        _verify_set_update_model_proxy_lambda_postconditions
    end

    def set_refresh_client(refresh_client)
        @refresh_client = refresh_client
    end

    def _verify_initialize_preconditions(player_rank)
        assert(player_rank.respond_to? :to_i, 'Given player rank cannot be converted to an integer')
        
        player_rank_i = player_rank.to_i
        assert(player_rank_i > 0 && player_rank_i < 3, 'Player rank must be 1 or 2')
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

    def _verify_other_player_update_model_preconditions
        other_player_rank = @player_rank == 1 ? 2 : 1;
        assert(@next_player == other_player_rank, 'Player 2 is not the next player to move')
    end

    def _verify_other_player_update_model_postconditions
    end

    def _verify_set_update_model_proxy_lambda_preconditions(update_model_proxy_lambda)
        assert(update_model_proxy_lambda.arity == 1,
                'Given model update proxy lambda must have an arity of 1')
    end

    def _verify_set_update_model_proxy_lambda_postconditions
    end
end
