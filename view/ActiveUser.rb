require "vrlib"

class ActiveUser < VR::ListView
 
  include GladeGUI

  def before_show()
    @builder["ActiveUserListView"].add(self)
    self.visible = true

  end

  def initialize
    @cols = {}
    @cols[:UserId] = String
    super(@cols)
    refresh()
    self.visible = true
  end
  
  def refresh()
    model.clear
    data = get_data()
    (0..data.length-1).each do |i|
      row = model.append
      row[id(:UserId)] = data[i][0]
    end
  end
  
  def get_data
    row = []
    row << ["A"]
    row << ["B"]

    row << ["C"]
  end

  def self__row_activated(*args)
    return unless rows = selected_rows
    row = rows[0]
    alert "You challenge #{row[:UserId]}"
  end

  def refreshActiveUser__clicked(*args)
    alert "refresh"
  end

end
