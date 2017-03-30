require_relative 'game'

class Connect4 < Game
    def categories
        [:Colour1, :Colour2]
    end

    def player_patterns
        [
            [:Colour1, :Colour1, :Colour1, :Colour1],
            [:Colour2, :Colour2, :Colour2, :Colour2]
        ]
    end

    def default_n_rows
        6
    end

    def default_n_cols
        7
    end
end
