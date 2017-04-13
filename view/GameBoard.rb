require "vrlib"
require_relative "LeaderBoardView"
require_relative "History"
require_relative "ActiveUser"
require_relative '../controller/controller'

class GameBoard

  include GladeGUI

  def check_class_invariants
    # assert(@builder, "There must be a gtk builder to display UI")
    assert(@controller, "There must be a controller")
  end

  def before_show()
    @window1 = "GameBoard"
    arr = Array.new(42)

    @button = arr
    0.upto(41) { |i|
       @builder.get_object("button[" + i.to_s + "]").signal_connect("clicked") {button_clicked(i)};
    }
    @controller = Controller.new([self], :OttoNToot, :ONE_PLAYER, 1)

    @red = "red"
    @blue = "blue"
  end

  def menuitem2__activate(*args)
    alert "New Practice Connect4"
  end

  def menuitem5__activate(*args)
    alert "New Practice OttoNToot"
  end

  def menuitem3__activate(*args)
    alert "New Challenge Connect4"
    ActiveUser.new.show_glade()

  end

  def menuitem6__activate(*args)
    alert "New Challenge OttoNToot"
    ActiveUser.new.show_glade()

  end

  def leaderboardmenuitem__activate(*args)
    LeaderBoardView.new.show_glade()
  end

  def historymenuitem__activate(*args)
    History.new.show_glade()
  end

  def quit__activate(*args)
    @builder["window1"].destroy
  end

  def setUpTheBoard (gameType = :OttoNToot, virtual_player = false)
      @gameType = gameType
      @controller = Controller.new([self], gameType, virtual_player)

      check_class_invariants
  end

  def button_clicked(tileNumber)
    @controller.player_update_model(tileNumber % 7)

    # tmp = @builder.get_object("button" + tileNumber.to_s).label
    # if tmp == @blankTile
    #    if @turn == @t
    #       @turn = @o
    #       # @builder.get_object("button" + tileNumber.to_s).set_label(T)
    #       Gtk.modify@builder.get_object("button" + tileNumber.to_s)
    #    else
    #       @turn = @t
    #       @builder.get_object("button" + tileNumber.to_s).set_label(O)
    #    end
    # end
    #
    # if win?
    #   system("clear")
    #   if @turn == @t
    #     popup ("Player O is the winner")
    #   else
    #     popup ("Player T is the winner")
    #   end
    # end
    check_class_invariants
  end

  def update (positions, victory)
    positions.each_with_index do | x, xi |
      x.each_with_index do | y, yi |
          button = @builder.get_object("button[" + (xi*(x.length) + yi).to_s + "]")
          if @gameType == :Connect4
              if y
                  colour = y == :Blue ? @blue : @red
                  button.set_label(colour)
                  # button.set_style colour
              end
          else
              button.set_label(y.to_s)
          end
      end
      check_class_invariants
    end

    if victory != nil
      # victory.positions.each_with_index do | x, xi |
      #   if xi % 2 != 0
      #     next
      #   else
      #     # Set color somehow
      #     @builder.get_object("button" + (x*length(positions[0]) + victory.positions[xi + 1])).
      #   end
      # end
      alert "Player placing " + victory.winner.category.to_s + " to get pattern " \
      + victory.pattern.to_s + " has won in positions " + victory.positions.to_s + "!"
    end
    check_class_invariants
  end

end

GameBoard.new.show_glade()
