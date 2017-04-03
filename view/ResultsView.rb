require 'test/unit/assertions'
include Test::Unit::Assertions

class ResultsView

  def check_class_invariants
    assert(@builder, "There must be a gtk builder to display UI")
    assert(@controller, "There must be a controller")
  end

  def initialize

    if __FILE__ == $0
      Gtk.init

  # Call this function before using any other GTK+ functions in your GUI
  # applications. It will initialize everything needed to operate the toolkit
  # and parses some standard #command line options. argv are adjusted accordingly
  # so your own code will never see those standard arguments. # attr :glade

      @builder = Gtk::Builder::new
  #http://ruby-gnome2.sourceforge.jp/hiki.cgi?Gtk%3A%3ABuilder

     @controller = Controller.new([self], :OttoNToot, false)

    end
    check_class_invariants
  end

  def setUpLeaderBoard(data)
    check_class_invariants
  end

  def setUpGameHistory( data )
    check_class_invariants
  end

  def popup( message, destroyBlock = lambda {} )
    check_class_invariants
  end

  def update( data )
    check_class_invariants
  end

  def filterByParameters( parameters )
    check_class_invariants
  end

end
