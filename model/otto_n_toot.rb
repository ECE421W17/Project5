require_relative 'game'

class OttoNToot < Game

    def categories
        [:O, :T]
    end

    def player_patterns
        [
            [:O, :T, :T, :O],
            [:T, :O, :O, :T]
        ]
    end

    def default_n_rows
        6
    end

    def default_n_cols
        7
    end
end
