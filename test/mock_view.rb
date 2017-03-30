class MockView
    attr_accessor :victory, :board

    def initialize
        @board = nil
        @victory = nil
    end

    def update(positions, victory)
        @board = positions
        @victory = victory
    end
end