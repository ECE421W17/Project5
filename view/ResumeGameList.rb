require "vrlib"

class ResumeGameList < VR::ListView
 
  include GladeGUI

  def before_show()
    @builder["ActiveUserListView"].add(self)
    self.visible = true

  end

  def initialize
    @cols = {}
    @cols[:GameId] = String
    @cols[:OppoentID] = String
    super(@cols)
    refresh()
    self.visible = true
  end
  
  def refresh()
    model.clear
    data = get_data()
    (0..data.length-1).each do |i|
      row = model.append
      row[id(:GameId)] = data[i][0]
      row[id(:Oppoent_ID)] = data[i][1]
    end
  end
  
  def get_data
    row = []
    row << ["A", "User1"]
    row << ["B", "User2"]
    row << ["C", "User3"]
  end

  def refreshResumeGame__clicked(*args)
    alert "refresh"
  end

  def self__row_activated(*args)
    return unless rows = selected_rows
    row = rows[0]
    alert "You select GameId #{row[:GameId]}, Oppoent #{row[:OppoentID]}}"
  end
end

