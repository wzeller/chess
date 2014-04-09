


#promp input

#invers(input)

class Game

  def initialize
    @board = Board.new
  end

  def play
    while true
      render
      get_user_input  #returns a string
      update_board
      framebuffer << @board.stage
    end
  end


  def render
    print "\e[2J"  #clear screen
    print framebuffer.join
    framebuffer = []
  end


end