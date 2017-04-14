require 'vrlib'
require_relative "GameBoard"

class Login

  include GladeGUI

  attr_accessor :screen_name, :database_ip, :database_port, :local_port

  def initialize()
    @screen_name = "a"
    @database_ip = "172.28.103.88"
    @database_port = "8080"
    @local_port = "8081"
  end

  def buttonShow__clicked(*args)

    get_glade_variables() #sets values of @name, @address etc. to values from glade form.
    GameBoard.new(@screen_name, @database_ip, @database_port, @local_port).show_glade
    @builder["buttonShow"].visible = false
    @builder["buttonCancel"].label = "Logout"
  end

  def buttonCancel__clicked(*args)
    @builder["window1"].destroy
  end

end

Login.new.show_glade()
# GameBoard.new("a", "172.28.77.251", 8080, 8081).show_glade()
