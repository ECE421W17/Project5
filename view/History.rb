require "vrlib"

class History < VR::ListView
 
  include GladeGUI

  def before_show()
    @builder["HistoryListView"].add(self)
    self.visible = true
    @HistoryMode = "All"
    @HistoryUserID = ""
    @HistoryGameID = ""
    @HistoryStatus = "All"
  end  

  def refreshHistory__clicked(*args)
    get_glade_variables()
    alert "Current values: \n\n"\
          "Mode:#{@HistoryMode}\n"\
          "UsrID: #{@HistoryUserID} \n"\
          "GameID: #{@HistoryGameID}\n"\
          "Status #{@HistoryStatus}"
  end

  def initialize(client, player)
    @client = client
    @player = player
    @cols = {}
    @cols[:GameID] = String
    # @cols[:Player1_ID] = String    
    # @cols[:Player2_ID] = String
    # @cols[:Game_mode] = String
    # @cols[:Winner] = String
    # @cols[:Status] = String

    super(@cols)

    refresh()
    self.visible = true
  end  

  def refresh()
    model.clear
    data = get_data() # returns array of songs
    (0..data.length-1).each do |i|
      row = model.append # add_row()
      row[id(:GameID)] = data[i][0]
      # row[id(:Player1_ID)] = data[i][1] 
      # row[id(:Player2_ID)] = data[i][2]
      # row[id(:Game_mode)] = data[i][3]
      # row[id(:Winner)] = data[i][4]
      # row[id(:Status)] = data[i][5]

    end

  end

  def get_data
    rows = @client.history(@player)
    # rows << ["A", "0","1","Connect4","0","Finished"]
    # rows << ["B", "2","1","OttoNToot","1","Finished"]
    # rows << ["C", "3","2","Connect4","3","Unfinished"]
    # rows << ["D", "2","3","OttoNToot","3","Finished"]
    # rows << ["E", "0","2","Connect4","0","Finished"]
    # rows << ["F", "0","3","Connect4","3","Unfinished"]
    # rows << ["G", "1","3","OttoNToot","3","Finished"]
  end
end

