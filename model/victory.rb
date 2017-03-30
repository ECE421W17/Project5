require 'test/unit/assertions'

include Test::Unit::Assertions

class Victory
    # A data class to represent a winning condition
    # Shows the player who won and the positions in the board
    # where their winning pattern is

    attr_accessor :winner, :positions

    def check_class_invariants
        assert(@winner, 'Victory must have a winning player')
        assert(@positions, 'Victory must have winning positions')
        assert(!@positions.empty?, 'There must be at least one position')
    end

    def initialize_pre_cond
    end

    def initialize_post_cond
    end

    def initialize(winner, positions)
        initialize_pre_cond
        # implement
        @winner = winner
        @positions = positions
        initialize_post_cond
        check_class_invariants
    end
end