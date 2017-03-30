require 'test/unit/assertions'

include Test::Unit::Assertions

class Player

    attr_accessor :category, :winning_pattern, :isVirtual

    def check_class_invariants
        assert(@category, 'Player must have a category')
        assert(@winning_pattern, 'Player must have a winning pattern')
    end

    def initialize_pre_cond
    end

    def initialize_post_cond
    end

    def initialize(category, winning_pattern, isVirtual)
        initialize_pre_cond
        @category = category
        @winning_pattern = winning_pattern
        @isVirtual = isVirtual
        initialize_post_cond
        check_class_invariants
    end

    def getWinningPattern
        winning_pattern
    end

    def getCategory
        category
    end

    def ==(other)
        if !other || (other.class != self.class)
            return false
        end

        other.category == category && other.winning_pattern == winning_pattern
    end

    def isVirtual
        @isVirtual
    end
end