require "vrlib"
require_relative "../server/game_client"

class ActiveUser < VR::ListView

  include GladeGUI

  def before_show()
    @builder["ActiveUserListView"].add(self)
    self.visible = true

  end

  def initialize(client)
    @client = client
    @cols = {}
    @cols[:UserId] = String
    @cols[:select] = TrueClass
    super(@cols)
    refresh()
    self.visible = true
  end

  def refresh()
    model.clear
    data = @client.get_online_players
    (0..data.length-1).each do |i|
      row = model.append
      row[id(:UserId)] = data[i][0]
      row[id(:select)] = false;
    end
  end

  def get_data
    row = []
    row << ["A"]
    row << ["B"]

    row << ["C"]
  end

  def challengeButton__clicked(*args)
    alert "You select challenge"

    # (0..selected_rows.length-1).each do |i|
    #   row = selected_rows[i]
    #   alert "You selected \n #{row[:UserId]}"
    # end

  end

  def refreshActiveUser__clicked(*args)
    alert "refresh"
  end

end

#ActiveUser.new.show_glade()
