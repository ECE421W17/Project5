class StubView
    def initialize(player_mode)
        @player_mode = player_mode
    end

    def update(positions, victory)
        if victory != nil
            if victory.get_winner.category == @player_mode
                puts 'Congratulations!!!! You won!!!'
            else
                puts 'Sorry!! You lost :('
            end
        end
    end
end