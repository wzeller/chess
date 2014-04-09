require './position.rb'
require './pieces.rb'
require 'colorize'
require 'debugger'


class Board
  attr_accessor :board
  def initialize
    make_board
    @captured_pieces = []

  end

  def [](pos)
    return @board[pos[0]][pos[1]]
  end

  def []=(pos,new_piece)
    @board[pos[0]][pos[1]] = new_piece
  end

  def size
    return @board.length
  end

  def make_board

    @board = Array.new(8){Array.new(8)}
    @board[0] = [Rook.new(:black,Pos.new([0,0]),self),
                Knight.new(:black,Pos.new([0,1]),self),
                Bishop.new(:black,Pos.new([0,2]),self),
                Queen.new(:black,Pos.new([0,3]),self),
                King.new(:black,Pos.new([0,4]),self),
                Bishop.new(:black,Pos.new([0,5]),self),
                Knight.new(:black,Pos.new([0,6]),self),
                Rook.new(:black,Pos.new([0,7]),self)]

    @board[1] = []
    8.times do |i|
      @board[1] << Pawn.new(:black, Pos.new([1,i]), self)
    end

    @board[6] = []
    8.times do |i|
      @board[6] << Pawn.new(:white, Pos.new([6,i]), self)
    end

    @board[7] = [Rook.new(:white, Pos.new([7,0]),self),
                Knight.new(:white, Pos.new([7,1]),self),
                Bishop.new(:white, Pos.new([7,2]),self),
                Queen.new(:white, Pos.new([7,3]),self),
                King.new(:white, Pos.new([7,4]),self),
                Bishop.new(:white, Pos.new([7,5]),self),
                Knight.new(:white, Pos.new([7,6]),self),
                Rook.new(:white, Pos.new([7,7]),self)]

    @board_color = Array.new(8){Array.new(8)}
    switch = false
    (0...8).each do |row|
      switch = !switch
      (0...8).each do |col|
        if switch == true
          @board_color[row][col] = :light_white
        else
          @board_color[row][col] = :light_black
        end
        switch = !switch
      end
    end
  end

  def stage
    buffer = Array.new(8){Array.new(8)}
    frame = []
    (0...8).each do |row|
      (0...8).each do |col|
        square = @board_color[row][col]
        if @board[row][col].nil?
          frame << "   ".colorize({background: square})
        else
          piece = @board[row][col]
          frame << (" " + piece.symbol + " ").colorize({color: piece.color, background: square, bold: true})
        end
      end
      frame <<  "\n"
    end

    return frame.join

  end

  def is_square_in_check?(square, opponent_color)
    square = Pos.new(square)
    (0...8).each do |row|
      (0...8).each do |col|
        next if @board[row][col].nil?
        next unless @board[row][col].color == opponent_color
        
        #skip king for now
        next if @board[row][col].type == :King

        return true if @board[row][col].can_move?(square)
      end
    end
    return false
  end
end

board = Board.new

pos1 = [7,1]
pos2 = [5,2]
pos3 = [6,3]
pos4 = [4,3]
pos5 = [7,3]
pos6 = [5,3]
pos7 = [3,5]
pos8 = [3,0]
pos9 = [1,0]
pos10 = [0,0]
pos11 = [1,0]
board[Pos.new(pos1)].move(Pos.new(pos2))
board[Pos.new(pos3)].move(Pos.new(pos4))
board[Pos.new(pos5)].move(Pos.new(pos6))
board[pos6].move(Pos.new(pos7))
board[pos7].move(Pos.new(pos8))
board[pos8].move(Pos.new(pos9))
board[pos10].move(pos11)
p board.is_square_in_check?([5,2], :white)
p board.is_square_in_check?([6,0], :black)

print board.stage

