require "vrlib"
require_relative "../server/game_client"

class ActiveUser < VR::ListView

  include GladeGUI

  def before_show()
    @builder["ActiveUserListView"].add(self)
    self.visible = true

  end

  def initialize(client, game_type, screen_name, function)
    @screen_name = screen_name
    @function = function
    @client = client
    @cols = {}
    @cols[:UserId] = String
    @game_type = game_type
    super(@cols)
    refresh()
    self.visible = true
  end

  def refresh()
    model.clear
    data = @client.get_online_players
    (0..data.length-1).each do |i|
      if data[i][0] != @screen_name
        row = model.append
        row[id(:UserId)] = data[i][0]
      end
    end
  end

  def self__row_activated(*args)
    return unless rows = selected_rows
    row = rows[0]
    alert "You challenge #{row[:UserId]}"
    @function.call(@client.issue_challenge(row[:UserId], @game_type))
    @builder["window1"].destroy
  end

  def refreshActiveUser__clicked(*args)
    alert "refresh"
  end

end
