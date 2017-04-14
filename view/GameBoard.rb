require "vrlib"
require_relative "LeaderBoardView"
require_relative "History"
require_relative "ActiveUser"
require_relative "ResumeGameList"
require_relative "Challenger"
require_relative '../controller/controller'

require 'pp'
require 'socket'
require 'xmlrpc/client'
require 'yaml' # TODO: Remove?

require_relative '../server/game_client'
require_relative '../server/game_server'
require_relative '../db/games_database_client'

class GameBoard

  attr_accessor :screen_name, :database_ip, :database_port, :local_port

  include GladeGUI

  def check_class_invariants
    # assert(@builder, "There must be a gtk builder to display UI")
    assert(@controller, "There must be a controller")
  end

  def before_show
    print @screen_name
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

  def initialize(screen_name, database_ip, database_port, local_port)
    @screen_name = "a"
    database_ip = "172.31.0.174"
    database_port = 8080
    local_port = 8081
    launch_local_game_server(@screen_name, database_ip, database_port, local_port)

    # TODO: Extract address to global scope
    # TODO: Wait for server to come up?...

    @local_ip_address =
        Socket.ip_address_list.find { |ai| ai.ipv4? && !ai.ipv4_loopback? }.ip_address

    @client = GameClient.new(
        {:game_server_ip => @local_ip_address, :game_server_port => local_port})
    @database_client = GamesDatabaseClient.new(
        {:games_database_server_ip=>database_ip, :games_database_server_port=>database_port})
  end

  def launch_local_game_server(screen_name, games_database_server_ip, games_database_server_port, game_server_port)
      @local_server_pid = Process.fork do
          # TODO: Extract address to global scope
          gs = GameServer.new(
              {:games_database_ip => games_database_server_ip,
                  :games_database_port => games_database_server_port,
                      :game_server_port => game_server_port, :screen_name => screen_name})
          gs.serve
      end
  end

  def menuitem2__activate(*args)
    alert "New Practice Connect4"
    @controller = Controller.new([self], :Connect4, :ONE_PLAYER, 1)
    0.upto(41) { |i|
       @builder.get_object("button[" + i.to_s + "]").set_label("")
    }
  end

  def menuitem5__activate(*args)
    alert "New Practice OttoNToot"
    @controller = Controller.new([self], :OttoNToot, :ONE_PLAYER, 1)
    0.upto(41) { |i|
       @builder.get_object("button[" + i.to_s + "]").set_label("")
    }
  end

  def menuitem3__activate(*args)
    alert "New Challenge Connect4"
    ActiveUser.new(@client, :Connect4, @screen_name, lambda{|controller|
      @controller = controller
      @controller.add_view(self)
    }).show_glade()

  end

  def menuitem6__activate(*args)
    alert "New Challenge OttoNToot"
    ActiveUser.new(@client, :OttoNToot, @screen_name, lambda{|controller|
      @controller = controller
      @controller.add_view(self)
    }).show_glade()

  end

  def resumeMenuItem__activate(*args)
    ResumeGameList.new.show_glade()
  end

  def challengeMenuItem__activate(*args)
    Challenger.new(@client, @screen_name, lambda{|controller| @controller = controller
                                                 @controller.add_view(self)}).show_glade()
  end

  def leaderboardmenuitem__activate(*args)
    LeaderBoardView.new(@database_client).show_glade(@client)
  end

  def historymenuitem__activate(*args)
    History.new.show_glade()
  end

  def quit__activate(*args)
    if @local_server_pid
      Process.kill('KILL', @local_server_pid)
    end
    @builder["window1"].destroy
  end

  def refreshbutton__clicked(*args)
      @controller.refresh
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
