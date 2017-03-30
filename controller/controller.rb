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


    def initialize(views, game, virtual_player)
        @views = views
        game_mode = virtual_player ? '1Player' : '2Player'
        @game = game == :Connect4 ?
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

	def update_model_pre_cond
	end

	def update_model_post_cond
	end

    # Views call this method in their event handlers
	def update_model(column_number)
        @game.make_move(@next_player, column_number)
        @next_player = @next_player == 1 ? 2 : 1
	end
end
