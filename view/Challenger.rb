require "vrlib"

class Challenger < VR::ListView

  include GladeGUI

  def before_show()
    @builder["ActiveUserListView"].add(self)
    self.visible = true

  end

  def initialize(client, screen_name, function)
    @screen_name = screen_name
    @function = function
    @client = client
    @cols = {}
    @cols[:Challenger_ID] = String
    super(@cols)
    refresh()
    self.visible = true
  end

  def refresh()
    model.clear
    data = @client.get_challenges
  
    data.each do |key, value|
      row = model.append
      row[id(:Challenger_ID)] = key
    end
  end

  def get_data
    row = []
    row << ["A"]
    row << ["B"]
    row << ["C"]
  end

  def refreshResumeGame__clicked(*args)
    refresh
  end

  def self__row_activated(*args)
    return unless rows = selected_rows
    row = rows[0]
    if alert("Do you challenge #{row[:Challenger_ID]}?", :button_yes => "Yes", :button_no => "No", :parent => self)
      alert "Accept Challenge"
      @function.call(@client.accept_challenge(row[:Challenger_ID]))
      @builder["window1"].destroy
    end
  end
end
#Challenger.new.show_glade()
