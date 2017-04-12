require "vrlib"
require_relative "LeaderBoardView"
require_relative "History"
require_relative "ActiveUser"

class GameBoard 
 
  include GladeGUI

  def before_show()
    @window1 = "GameBoard"
    arr = Array.new(42)
    @button = arr
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

end

GameBoard.new.show_glade()


