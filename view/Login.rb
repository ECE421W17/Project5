require 'vrlib'

class Login

  include GladeGUI


  def initialize()
    @screen_name = ""
    @database_ip = ""
    @database_port = ""
    @local_port = ""
  end

  def buttonShow__clicked(*args)
    get_glade_variables() #sets values of @name, @address etc. to values from glade form.
    alert "Curent values:\n\n#{@screen_name}\n#{@database_ip}\n#{@database_port}\n#{@local_port}\n"
  end


end

Login.new.show_glade()
