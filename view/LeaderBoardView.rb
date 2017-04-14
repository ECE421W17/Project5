require "vrlib"

class LeaderBoardView < VR::ListView
  include GladeGUI

  def before_show()
    @builder["LeaderBoardScrollWindow"].add(self)
    self.visible = true
    @TextEntryTopNumberOfPlayer = 10
    @LeaderBoardMode = "Total"
    @LeaderBoardWinningNumber = 10
    @LeaderBoardWinningPercentage = 0
    @LeaderBoardUserID = 0
  end

  def refreshLeaderBoard__clicked(*args)
    get_glade_variables()
    refresh()
    # alert "Current values: \n\n"\
    #       "Number of Result:#{@TextEntryTopNumberOfPlayer}\n"\
    #       "Mode: #{@LeaderBoardMode} \n"\
    #       "Number: #{@LeaderBoardWinningNumber}\n"\
    #       "Winning Percentage #{@LeaderBoardWinningPercentage} \n"\
    #       "UserID: #{@LeaderBoardUserID}"
  end
  def initialize(client)
    @client = client
    @cols = {}
    @cols[:id] = String
    @cols[:score] = String
    # @cols[:c4_win] = String
    # @cols[:c4_lost] = String
    # @cols[:c4_WinPercent] = String
    # @cols[:OnT_Total] = String
    # @cols[:OnT_W] = String
    # @cols[:OnT_L] = String
    # @cols[:OnT_WinPercent] = String
    # @cols[:T_Total] = String
    # @cols[:T_W] = String
    # @cols[:T_L] = String
    # @cols[:T_WinPercent] = String

    super(@cols)

    refresh()
    self.visible = true
  end

  # this just loads the data into the model
  def refresh()
    model.clear
    data = get_data() # returns array of songs
    (0..data.length-1).each do |i|
      row = model.append # add_row()
      row[id(:id)] = data[i][0]
      row[id(:score)] = data[i][1]
      # row[id(:c4_win)] = data[i][2]
      # row[id(:c4_lost)] = data[i][3]
      # row[id(:c4_WinPercent)] = data[i][4]
      # row[id(:OnT_Total)] = data[i][5]
      # row[id(:OnT_W)] = data[i][6]
      # row[id(:OnT_L)] = data[i][7]
      # row[id(:OnT_WinPercent)] = data[i][8]
      # row[id(:T_Total)] = data[i][9]
      # row[id(:T_W)] = data[i][10]
      # row[id(:T_L)] = data[i][11]
      # row[id(:T_WinPercent)] = data[i][12]
    end

  end

  def get_data
    rows = @client.top_players(@TextEntryTopNumberOfPlayer)
    # rows = []
    # rows << ["A", "0","0","0","0","1","1","1","1","2","2","2","2"]
    # rows << ["B", "1","1","1","1","2","2","2","2","3","3","3","3"]
    # rows << ["C", "0","0","0","0","1","1","1","1","2","2","2","1"]
    # rows << ["D", "0","0","0","0","1","1","1","1","2","2","2","1"]
    # rows << ["E", "0","0","0","0","1","1","1","1","2","2","2","1"]
    # rows << ["F", "0","0","0","0","1","1","1","1","2","2","2","1"]
    # rows << ["G", "0","0","0","0","1","1","1","1","2","2","2","1"]
  end
end
