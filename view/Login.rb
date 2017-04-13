require 'vrlib'
require_relative "GameBoard"

class Login

  include GladeGUI

  attr_accessor :screen_name, :database_ip, :database_port, :local_port

  def initialize()
    @screen_name = ""
    @database_ip = ""
    @database_port = ""
    @local_port = ""
  end

  def buttonShow__clicked(*args)
    get_glade_variables() #sets values of @name, @address etc. to values from glade form.
    gameboard = GameBoard.new
    gameboard.screen_name = @screen_name
    gameboard.show_glade(self)
    # gameboard.setup_client(@screen_name, @database_ip, @database_port, @local_port)
    # gameboard.show_glade
    # @builder["window1"].destroy
    # @screen_name @database_ip @database_port @local_port
  end


end

Login.new.show_glade()
